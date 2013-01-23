require 'spec_helper.rb'
require "digest/sha1"

describe "The uploader module" do
  before(:all) do
    # Create a reference to the uploader
    @module = S3Multipart::Uploader

    # Extend the module to trigger the "extended" hook
    class VideoUploader
      extend S3Multipart::Uploader::Core
    end
  end

  it "should serialize a controller" do
    # the upload controller passed into serialize can either
    # be the class itself or a string represention
    controller = VideoUploader
    sha1_digest = Digest::SHA1.hexdigest(controller.to_s)
    @module.serialize(VideoUploader).should eql(sha1_digest)
    @module.serialize(VideoUploader.to_s).should eql(sha1_digest)
  end

  it "should deserialize a controller" do
    # will always return the class constant
    controller = VideoUploader
    sha1_digest = Digest::SHA1.hexdigest(controller.to_s)
    @module.deserialize(sha1_digest).should eql(controller)
  end

end