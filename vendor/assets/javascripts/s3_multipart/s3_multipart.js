(function(global) {
  global.S3MP = (function() {

    // Wrap this into underscore library extension
    _.mixin({
      findIndex : function (collection, filter) {
        for (var i = 0; i < collection.length; i++) {
          if (filter(collection[i], i, collection)) {
            return i;
          }
        }
        return -1;
      }
    });

    // S3MP Constructor
    function S3MP(options) {
      var files
        , progress_timer = []
        , S3MP = this;

      // User defined options + callbacks
      options = options || {
        fileSelector: null,
        bucket: null,
        onStart: function(upload) {
          console.log("File "+upload.num+" has started uploading")
        },
        onComplete: function(upload) {
          console.log("File "+upload.num+" successfully uploaded")
        },
        onPause: function(num) {
          console.log("File "+num+" has been paused")
        },
        onCancel: function(num) {
          console.log("File upload "+num+" was canceled")
        },
        onError: function(num) {
          console.log("There was an error")
        },
        onProgress: function(num, size, done, percent, speed) {
          console.log("File %d is %f percent done (%f of %f total) and uploading at %s", num, percent, done, size, speed);
        }
      }
      _.extend(this, options);

      this.uploadList = [];

      // Handles all of the user input, success/failure events, and
      // progress notifiers
      this.handler = {

        // utility function to return an upload object given a file
        _returnUploadObj: function(file) {
          var uploadObj = _.find(S3MP.uploadList, function(uploadObj) {
            return uploadObj.file === file;
          });
          return uploadObj;   
        },

        // Activate an appropriate number of parts (number = pipes)
        // when all of the parts have been successfully initialized
        beginUpload: function() {
          var i = [];
          function beginUpload(pipes, uploadObj) {
            var key = uploadObj.key
              , num_parts = uploadObj.parts.length

            if (typeof i[key] === "undefined") {
              i[key] = 0;
            }

            i[key]++;

            if (i[key] === num_parts) {
              for (var j=0; j<pipes; j++) {
                uploadObj.parts[j].activate();
              }
              S3MP.handler.startProgressTimer(key);
              S3MP.onStart(uploadObj); // This probably needs to go somewhere else. 
            }
          }
          return beginUpload;
        }(),

        // cancel a given file upload
        cancel: function(file) {
          var uploadObj, i;

          uploadObj = this._returnUploadObj(file);
          i = _.indexOf(S3MP.uploadList, uploadObj);

          S3MP.uploadList.splice(i,i+1);
          S3MP.onCancel();
        },

        // pause a given file upload
        pause: function(file) {
          var uploadObj = this._returnUploadObj(file);
          
          _.each(uploadObj.activeParts, function(part, key, list) {
            part.xhr.abort();
          });

          S3MP.onPause();
        },

        // called when an upload is paused or the network connection cuts out
        onError: function(uploadObj, part) {
          // To-do
        },

        // called when a single part has successfully uploaded
        onPartSuccess: function(uploadObj, finished_part) {
          var parts, i, ETag;

          parts = uploadObj.parts;

          // Append the ETag (in the response header) to the ETags array
          ETag = finished_part.xhr.getResponseHeader("ETag");
          uploadObj.Etags.push({ ETag: ETag.replace(/\"/g, ''), partNum: finished_part.num });

          // Increase the uploaded count and delete the finished part 
          uploadObj.uploaded += finished_part.size;
          uploadObj.inprogress[finished_part.num-1] = 0;
          i = _.indexOf(parts, finished_part);
          parts.splice(i,1);

          // activate one of the remaining parts
          if (parts.length) {
            i = _.findIndex(parts, function(el, index, collection) {
              if (el.status !== "active") {
                return true;
              }
            });
            if (i !== -1){ 
              parts[i].activate();
            }
          }

          // If no parts remain then the upload has finished 
          if (!parts.length) {
            this.onComplete(uploadObj);
          }
        },

        // called when all parts have successfully uploaded
        onComplete: function(uploadObj) {
          var key = _.indexOf(S3MP.uploadList, uploadObj);
          
          // Stop the onprogress timer
          this.clearProgressTimer(key);

          // Tell the server to put together the pieces
          S3MP.completeMultipart(uploadObj, function(obj) {
            // Notify the client that the upload has succeeded when we
            // get confirmation from the server
            if (obj.location) {
              S3MP.onComplete(uploadObj);
            }
          });

        },

        // Called by progress_timer
        onProgress: function(key, size, done, percent, speed) {
          S3MP.onProgress(key, size, done, percent, speed);          
        },

        startProgressTimer: function() {
          var last_upload_chunk = [];
          var fn = function(key) {
            progress_timer[key] = global.setInterval(function() {
              var upload, size, done, percent, speed;

              if (typeof last_upload_chunk[key] === "undefined") {
                last_upload_chunk[key] = 0;
              }

              upload = S3MP.uploadList[key];
              size = upload.size;
              done = upload.uploaded;

              _.each(upload.inprogress,function(val) {
                done += val;
              });

              percent = done/size * 100;
              speed = done - last_upload_chunk[key];
              last_upload_chunk[key] = done;

              upload.handler.onProgress(key, size, done, percent, speed);
            }, 1000);
          };
          return fn;
        }(),

        clearProgressTimer: function(key) {
          global.clearInterval(progress_timer[key]);
        }

      };

      files = $(this.fileSelector).get(0).files;

      _.each(files, function(file, key) {
        //Do validation for each file before creating a new upload object
        // if (!file.type.match(/video/)) {
        //   return false;
        // }
        if (file.size < 5000000) {
          return false;
        }

        var upload = new Upload(file, S3MP, key);
        S3MP.uploadList.push(upload);
        upload.init();
      });

    };

    // Upload constructor
    function Upload(file, o, key) {
      function Upload() {
        var upload, id, parts, part, segs, chunk_segs, chunk_lens, pipes, blob;
        
        upload = this;
        
        this.key = key;
        this.file = file;
        this.name = file.name;
        this.size = file.size;
        this.type = file.type;
        this.Etags = [];
        this.inprogress = [];
        this.uploaded = 0;
        this.status = "";

        // Break the file into an appropriate amount of chunks
        // This needs to be optimized for various browsers types/versions
        if (this.size > 1000000000) { // size greater than 1gb
          num_segs = 100;
          pipes = 10;
        } else if (this.size > 500000000) { // greater than 500mb
          num_segs = 50;
          pipes = 5;
        } else if (this.size > 100000000) { // greater than 100 mb
          num_segs = 20;
          pipes = 5;
        } else if (this.size > 10000000) { // greater than 10 mb
          num_segs = 2;
          pipes = 2;
        } else { // Do not use multi-part uploader
          num_segs = 10;
          pipes = 3;
        }         

        chunk_segs = _.range(num_segs + 1);
        chunk_lens = _.map(chunk_segs, function(seg) {
          return Math.round(seg * (file.size/num_segs));
        });

        this.parts = _.map(chunk_lens, function(len, i) {
          blob = upload.sliceBlob(file, len, chunk_lens[i+1]);
          return new UploadPart(blob, i+1, upload);
        });

        this.parts.pop(); // Remove the empty blob at the end of the array

        // init function will initiate the multipart upload, sign all the parts, and 
        // start uploading some parts in parallel
        this.init = function() {
          upload.initiateMultipart(upload, function(obj) {
            console.log('Multipart initiation successful');
            var id = upload.id = obj.id
              , upload_id = upload.upload_id = obj.upload_id
              , object_name = upload.object_name = obj.name
              , parts = upload.parts;

            upload.signPartRequests(id, object_name, upload_id, parts, function(response) {
              _.each(parts, function(part, key) {
                var xhr = part.xhr;

                xhr.open('PUT', 'http://'+upload.bucket+'.s3.amazonaws.com/'+object_name+'?partNumber='+part.num+'&uploadId='+upload_id, true);
                xhr.setRequestHeader('x-amz-date', response[key].date);
                xhr.setRequestHeader('Authorization', response[key].authorization);

                // Notify handler that an xhr request has been opened
                upload.handler.beginUpload(pipes, upload);
              });
            });
          }); 
        } 
      };
      // Inherit the properties and prototype methods of the S3MP instance object
      Upload.prototype = o;
      return new Upload(); 
    }

    // Upload part constructor 
    function UploadPart(blob, key, upload) {
      var part, xhr;

      part = this;

      this.size = blob.size;
      this.blob = blob;
      this.num = key;

      this.xhr = xhr = upload.createXhrRequest();
      xhr.onload = function() {
        upload.handler.onPartSuccess(upload, part);
      };
      xhr.onerror = function() {
        upload.handler.onError(upload, part);
      };
      xhr.upload.onprogress = _.throttle(function(e) {
        upload.inprogress[key] = e.loaded;
      }, 1000);

    };

    UploadPart.prototype.activate = function() { 
      this.status = "active";     
      this.xhr.send(this.blob);
    };

    S3MP.prototype.initiateMultipart = function(upload, cb) {
      var url, body, request, response;

      url = '/s3_multipart/uploads';
      body = JSON.stringify({ object_name  : upload.name,
                              content_type : upload.type
                            });

      request = this.createXhrRequest('POST', url, function(xhr) {
        if (this.readyState !== 4) {
          return false;
        }
        if (this.status !== 200) {   
          throw {
            name: "ServerResponse",
            message: "The server responded with an error"
          }; 
        }

        response = JSON.parse(this.responseText);
        cb(response);        
      });

      request.setRequestHeader('Content-Type', 'application/json');
      request.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      
      request.send(body);

    };

    S3MP.prototype.signPartRequests = function(id, object_name, upload_id, parts, cb) {
      var content_lengths, url, body, request, response;

      content_lengths = _.reduce(_.rest(parts), function(memo, part) {
        return memo + "-" + part.size;
      }, parts[0].size);

      url = "s3_multipart/uploads/"+id;
      body = JSON.stringify({ object_name     : object_name,
                              upload_id       : upload_id,
                              content_lengths : content_lengths
                            });

      request = this.createXhrRequest('PUT', url, function(xhr) {
        if (this.readyState !== 4) {
          // Retry this chunk and give an error message
          return false;
        }
        if (this.status !== 200) {          
          // Retry this chunk and give an error message
          return false;
        }

        response = JSON.parse(this.responseText);
        cb(response);     
      });

      request.setRequestHeader('Content-Type', 'application/json');
      request.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      
      request.send(body);

    };

    S3MP.prototype.completeMultipart = function(uploadObj, cb) {
      var url, body, request, response;

      url = 's3_multipart/uploads/'+uploadObj.id;
      body = JSON.stringify({ object_name    : uploadObj.object_name,
                              upload_id      : uploadObj.upload_id,
                              content_length : uploadObj.size,
                              parts          : uploadObj.Etags
                            });

      request = this.createXhrRequest('PUT', url, function(xhr) {
        if (this.readyState !== 4) {
          // Retry this chunk and give an error message
          return false;
        }
        if (this.status !== 200) {          
          // Retry this chunk and give an error message
          return false;
        }

        response = JSON.parse(this.responseText);
        cb(response);
      })

      request.setRequestHeader('Content-Type', 'application/json');
      request.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      
      request.send(body);
    };

    S3MP.prototype.createXhrRequest = function() {
      var xhrRequest;

      // Sniff for xhr object
      if (typeof XMLHttpRequest.constructor === "function") { 
        xhrRequest = XMLHttpRequest;
      } else if (typeof XDomainRequest !== "undefined") {
        xhrRequest = XDomainRequest;
      } else {
        xhrRequest = null; // Error out to the client
      }

      return function(method, url, cb, open) { // open defaults to true
        var args, xhr, open = true;

        args = Array.prototype.slice.call(arguments);
        if (typeof args[0] === "undefined") {
          cb = null;
          open = false;
        } 

        xhr = new xhrRequest();
        if (open) { // open the request unless specified otherwise
          xhr.open(method, url, true); 
        }
        xhr.onreadystatechange = cb;

        return xhr;
      };

    }();    

    S3MP.prototype.sliceBlob = function() {
      var test_blob = new Blob();

      if (test_blob.slice) {
        return function(blob, start, end) {
          return blob.slice(start, end);
        }
      } else if (test_blob.mozSlice) {
        return function(blob, start, end) {
          return blob.mozSlice(start, end);
        }
      } else if (test_blob.webkitSlice) {
        return function(blob, start, end) {
          return blob.webkitSlice(start, end);
        }
      } else {
        throw new Error("File API not supported");
      }
    }();
    
    return S3MP;

  }());

}(this));