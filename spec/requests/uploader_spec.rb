require 'spec_helper.rb'
require 'setup_credentials.rb'

class UploaderTest
  include S3Multipart::Uploader
end

describe "Uploader module" do
  before(:all) do
    @uploader = UploaderTest.new
  end

  it "should initiate an upload" do
    response = @uploader.initiate(object_name: "example_object", content_type: "video/x-ms-wmv")
    response["upload_id"].should be_an_instance_of(String)
  end

end