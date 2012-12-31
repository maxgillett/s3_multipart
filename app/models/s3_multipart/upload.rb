module S3Multipart
  class Upload < ::ActiveRecord::Base
    class << self   
      include S3Multipart::Uploader 
      attr_accessor :on_complete_callback
    end

    attr_accessor :key, :upload_id, :name, :location
  end
end