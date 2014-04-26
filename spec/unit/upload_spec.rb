require 'spec_helper.rb'

describe "An upload object" do
  before(:all) do
    class Upload
      include S3Multipart::TransferHelpers
    end
    @upload = Upload.new
  end

  it "should initiate an upload" do
    @upload.stub(:unique_name) {'name'}
    response = @upload.initiate( object_name: "example_object.wmv",
                                  content_type: "video/x-ms-wmv" )

    response["upload_id"].should be_an_instance_of(String)
    response["key"].should be_an_instance_of(String)
    response["name"].should be_an_instance_of(String)
  end

  it "should sign many parts" do
    response = @upload.sign_batch(    object_name: "example_object",
                                    content_lengths: "1000000-1000000-1000000",
                                          upload_id: "a83jrhfs94jcj3c3" ) 

    response.should be_an_instance_of(Array)
    response.first[:authorization].should match(/AWS/)
  end

  it "should sign a single part" do
    response = @upload.sign_part(   object_name: "example_object",
                                   content_length: "1000000",
                                        upload_id: "a83jrhfs94jcj3c3" ) 

    response.should be_an_instance_of(Hash)
    response[:authorization].should match(/AWS/)
  end

  it "should unsuccessfully attempt to complete an upload that doesn't exist" do
    response = @upload.complete(    object_name: "example_object",
                                   content_length: "1000000",
                                            parts: [{partNum: 1, ETag: "jf93nda3Sf8FSh"}],
                                     content_type: "application/xml",
                                        upload_id: "a83jrhfs94jcj3c3" ) 

    response[:error].should eql("Upload does not exist")
  end
end
