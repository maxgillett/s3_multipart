module S3Multipart
  class Upload < ::ActiveRecord::Base
    class << self   
      include S3Multipart::TransferHelpers
      # attr_accessor :on_complete_callback
      # attr_accessor :on_begin_callback
    end

    attr_accessible :key, :upload_id, :name, :location, :uploader

    def execute_callback(stage)

    end

  end
end