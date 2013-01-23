require 'spec_helper.rb'

describe "An upload controller" do

  before(:all) do
    class Uploader
      extend S3Multipart::Uploader::Core
    end
  end

  it "should set up callbacks" do
    Uploader.class_eval do
      on_begin do |upload|
        "Upload has begun"
      end

      on_complete do |upload|
        "Upload has completed"
      end
    end

    Uploader.on_begin_callback.call.should eql("Upload has begun")
    Uploader.on_complete_callback.call.should eql("Upload has completed")
  end

  it "should attach a model to the uploader" do
    Uploader.attach :video
    S3Multipart::Upload.new.respond_to?(:video).should be_true
  end

end