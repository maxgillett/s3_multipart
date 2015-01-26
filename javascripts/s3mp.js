// S3MP Constructor
function S3MP(options) {
  var files
    , progress_timer = []
    , S3MP = this;

  _.extend(this, options);
  this.headers = _.object(_.map(options.headers, function(v,k) { return ["x-amz-" + k.toLowerCase(), v] }));

  this.uploadList = [];

  // Handles all of the success/failure events, and
  // progress notifiers
  this.handler = {

    // Activate an appropriate number of parts (number = pipes)
    // when all of the parts have been successfully initialized
    beginUpload: function() {
      var i = [];
      function beginUpload(pipes, uploadObj) {
        var key = uploadObj.key
          , num_parts = uploadObj.parts.length;

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

    // called when an upload is paused or the network connection cuts out
    onError: function(uploadObj, part) {
      // To-do
    },

    // called when a single part has successfully uploaded
    onPartSuccess: function(uploadObj, finished_part) {
      var parts, i, ETag;

      parts = uploadObj.parts;
      finished_part.status = "complete";

      // Append the ETag (in the response header) to the ETags array
      ETag = finished_part.xhr.getResponseHeader("ETag");
      uploadObj.Etags.push({ ETag: ETag.replace(/\"/g, ''), partNum: finished_part.num });

      // Increase the uploaded count and delete the finished part 
      uploadObj.uploaded += finished_part.size;
      uploadObj.inprogress[finished_part.num] = 0;
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

  // List of files may come from a FileList object or an array of files
  if (this.fileSelector) {
    files = $(this.fileSelector).get(0).files; // FileList object
  } else {
    files = this.fileList; // array specified in configuration
  }

  _.each(files, function(file, key) {
    var upload = new Upload(file, S3MP, key);
    S3MP.uploadList.push(upload);
    upload.init();
  });

};

S3MP.prototype.initiateMultipart = function(upload, cb) {
  var url, body, xhr;

  url = '/s3_multipart/uploads';
  body = JSON.stringify({ object_name  : upload.name || $(this.fileInputElement).data("filename"),
                          content_type : upload.type,
                          content_size : upload.size,
                          headers      : this.headers,
                          context      : $(this.fileInputElement).data("context"),
                          uploader     : $(this.fileInputElement).data("uploader")
                        });

  xhr = this.createXhrRequest('POST', url);
  this.deliverRequest(xhr, body, cb);

};

S3MP.prototype.signPartRequests = function(id, object_name, upload_id, parts, cb) {
  var content_lengths, url, body, xhr;

  content_lengths = _.reduce(_.rest(parts), function(memo, part) {
    return memo + "-" + part.size;
  }, parts[0].size);

  url = "/s3_multipart/uploads/"+id;
  body = JSON.stringify({ object_name     : object_name,
                          upload_id       : upload_id,
                          content_lengths : content_lengths
                        });

  xhr = this.createXhrRequest('PUT', url);
  this.deliverRequest(xhr, body, cb);
};

S3MP.prototype.completeMultipart = function(uploadObj, cb) {
  var url, body, xhr;

  url = '/s3_multipart/uploads/'+uploadObj.id;
  body = JSON.stringify({ object_name    : uploadObj.object_name,
                          upload_id      : uploadObj.upload_id,
                          content_length : uploadObj.size,
                          parts          : uploadObj.Etags
                        });

  xhr = this.createXhrRequest('PUT', url);
  this.deliverRequest(xhr, body, cb);
};

// Specify callbacks, request body, and settings for requests that contact
// the site server, and send the request.
S3MP.prototype.deliverRequest = function(xhr, body, cb) {
  var self = this;
  
  xhr.onload = function() {
    response = JSON.parse(this.responseText);
    if (response.error) { 
      return self.onError({
        name: "ServerResponse",
        message: response.error
      });  
    }
    cb(response);
  };

  xhr.onerror = function() {
    // To-do: Handle communication errors
  };

  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));

  xhr.send(body);
}

S3MP.prototype.createXhrRequest = function() {
  var xhrRequest;

  // Sniff for xhr object
  if (typeof XMLHttpRequest.constructor === "function") { 
    xhrRequest = XMLHttpRequest;
  } else if (typeof XDomainRequest !== "undefined") {
    xhrRequest = XDomainRequest;
  } else {
    xhrRequest = null; // Error out to the client (To-do) 
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
  try {
    var test_blob = new Blob();
  } catch(e) {
    return "Unsupported";
  }

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
    return "Unsupported";
  }
}();

// utility function to return an upload object given a file
S3MP.prototype._returnUploadObj = function(key) {
  var uploadObj = _.find(this.uploadList, function(uploadObj) {
    return uploadObj.key === key;
  });
  return uploadObj;   
};

// cancel a given file upload
S3MP.prototype.cancel = function(key) {
  var uploadObj, i;

  uploadObj = this._returnUploadObj(key);
  i = _.indexOf(this.uploadList, uploadObj);

  this.uploadList.splice(i,i+1);
  this.onCancel();
};

// pause a given file upload
S3MP.prototype.pause = function(key) {
  var uploadObj = this._returnUploadObj(key);
  
  _.each(uploadObj.parts, function(part, key, list) {
    if (part.status == "active") {
      part.pause();
    }
  });

  this.onPause();
};

// resume a given file upload
S3MP.prototype.resume = function(key) {
  var uploadObj = this._returnUploadObj(key);
  
  _.each(uploadObj.parts, function(part, key, list) {
    if (part.status == "paused") {
      part.activate();
    }
  });

  this.onResume();          
};
