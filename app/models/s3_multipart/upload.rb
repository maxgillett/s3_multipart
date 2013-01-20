module S3Multipart
  class Upload < ::ActiveRecord::Base
    extend S3Multipart::TransferHelpers

    attr_accessible :key, :upload_id, :name, :location, :uploader

    def execute_callback(stage)
      uploader = S3Multipart::Uploader.deserialize(uploader)
      
      case state
      when :begin
        uploader.on_begin_callback.call(self)
      when :complete
        uploader.on_complete_callback.call(self)
      end
    end

  end
end