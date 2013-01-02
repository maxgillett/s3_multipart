class PagesController < ApplicationController

  def upload
    attach_uploader do |upload|
      upload.update_attributes(name: "modified")
    end
  end

end
