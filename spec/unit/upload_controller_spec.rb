require 'spec_helper.rb'

describe "An upload controller" do

  before(:all) do
    class GenericUploader
      extend S3Multipart::Uploader::Core
    end
  end

  it "should set up callbacks" do
    GenericUploader.class_eval do
      on_begin do |upload|
        "Upload has begun"
      end

      on_complete do |upload|
        "Upload has completed"
      end
    end

    GenericUploader.on_begin_callback.call.should eql("Upload has begun")
    GenericUploader.on_complete_callback.call.should eql("Upload has completed")
  end

  it "should attach a model to the uploader" do
    GenericUploader.attach :video
    S3Multipart::Upload.new.respond_to?(:video).should be_true
  end

  it "should store the allowed file types" do
    hash = { extensions: %w(wmv avi mp4 mkv mov mpeg flv), mime_types: %w(video/*) }
    GenericUploader.accept(hash)
    GenericUploader.extensions.should eql(hash[:extensions])
    GenericUploader.mime_types.should eql(hash[:mime_types])
  end

end
