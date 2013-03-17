#  require 'spec_helper.rb'
#  require "digest/sha1"
#
#  describe "Uploads controller" do
#    it "should create an upload" do
#      post '/s3_multipart/uploads', {object_name: "example_object.wmv", content_type: "video/x-ms-wmv", uploader: Digest::SHA1.hexdigest("VideoUploader")}
#      parsed_body = JSON.parse(response.body)
#      parsed_body.should_not eq({"error"=>"There was an error initiating the upload"})
#    end
#  end
