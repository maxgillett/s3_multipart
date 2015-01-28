// Upload part constructor 
function UploadPart(blob, key, upload) {
  var part, xhr;

  part = this;

  this.size = blob.size;
  this.blob = blob;
  this.num = key;
  this.upload = upload;

  this.xhr = xhr = upload.createXhrRequest();
  xhr.onload = function() {
    upload.handler.onPartSuccess(upload, part);
  };
  xhr.onerror = function() {
    upload.handler.onError(upload, part);
  };
  xhr.upload.onprogress = _.throttle(function(e) {
    if (e.lengthComputable) {
      upload.inprogress[key] = e.loaded;
    }
  }, 1000);

};

UploadPart.prototype.activate = function() { 
  this.xhr.open('PUT', '//'+this.upload.bucket+'.s3.amazonaws.com/'+this.upload.object_name+'?partNumber='+this.num+'&uploadId='+this.upload.upload_id, true);
  this.xhr.setRequestHeader('x-amz-date', this.date);
  this.xhr.setRequestHeader('Authorization', this.auth);

  this.xhr.send(this.blob);
  this.status = "active";
};

UploadPart.prototype.pause = function() {
  this.xhr.abort();
  this.status = "paused";
};
