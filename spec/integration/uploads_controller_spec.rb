require 'spec_helper.rb'

describe "Uploads controller" do
  it "should create an upload" do
    post '/s3_multipart/uploads', {object_name: "example_object", content_type: "video/x-ms-wmv"}
    parsed_body = JSON.parse(response.body)
    parsed_body.should_not eq({"error"=>"There was an error initiating the upload"})
  end
end