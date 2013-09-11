require "spec_helper"

describe "File upload", :sauce => true do
  it "should go through locally" do
    visit "http://localhost:9000"
#    attach_file("uploader", "http://localhost:9000/slug.wmv")
#    page.find(".submit-button").click
     element = Capybara.current_driver.find_element(:id, 'uploader')
     element.send_keys "Users/Max/Dropbox/slug.wmv"
     page.find(".submit-button").click
  end 
end
