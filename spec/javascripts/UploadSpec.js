describe("An upload", function() {
  var upload;

  beforeEach(function() {
    var s3mp, file;

    s3mp = new S3MP({
      bucket: 's3mp-test-bucket'
    });

    spyOn(s3mp.handler, 'beginUpload');
    spyOn(s3mp, 'createXhrRequest').andCallThrough();

    spyOn(s3mp, 'initiateMultipart').andCallFake(function(upload, callback) {
      callback({
        id: 0,
        upload_id: "A1S2D3F4",
        key: "A1A2-B1B2-C1C2-D1D2"
      });
    });

    spyOn(s3mp, 'signPartRequests').andCallFake(function(id, object_name, upload_id, parts, callback) {
      callback([{authorization:"AWS authorization code 1", date:"Thu, 24 Jan 2013 20:36:25 EST"},
                {authorization:"AWS authroization code 2", date:"Thu, 24 Jan 2013 20:36:25 EST"}]);
    });
    
    spyOn(s3mp, 'sliceBlob').andCallFake(function(blob, start, end) {
      blob.size = end - start;
      return blob;
    });

    file = {
      name: 'test.mkv',
      size: 7500000,
      type: 'video/mkv'
    };

    upload = new Upload(file, s3mp, 0);

  });

  it("has multiple parts", function() {
    expect(upload.parts[0].constructor).toBe(UploadPart);
    expect(upload.parts[1].constructor).toBe(UploadPart);
  });

  describe("when initiated", function() {
    
    it("makes a call to initiateMultipart", function() {
      upload.init();  
      expect(upload.initiateMultipart).toHaveBeenCalled();
      expect(upload.initiateMultipart.mostRecentCall.args[0]).toEqual(upload);
      expect(upload.initiateMultipart.mostRecentCall.args[1].constructor).toEqual(Function);
    });

    it("signs all of the part requests", function() {
      upload.init();
      expect(upload.signPartRequests).toHaveBeenCalled();
      expect(upload.signPartRequests.mostRecentCall.args[0]).toEqual(0);
      expect(upload.signPartRequests.mostRecentCall.args[1]).toEqual("A1A2-B1B2-C1C2-D1D2");
      expect(upload.signPartRequests.mostRecentCall.args[2]).toEqual("A1S2D3F4");
      expect(upload.signPartRequests.mostRecentCall.args[3]).toEqual(upload.parts);
      expect(upload.signPartRequests.mostRecentCall.args[4].constructor).toEqual(Function);
    });

    it("starts uploading parts in parallel", function() {
      upload.init();
      expect(upload.handler.beginUpload.calls.length).toEqual(2);
      expect(upload.handler.beginUpload.mostRecentCall.args[0]).toEqual(2);
      expect(upload.handler.beginUpload.mostRecentCall.args[1]).toEqual(upload);
    });

  });

});