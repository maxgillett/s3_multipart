module S3Multipart
  class Upload < ::ActiveRecord::Base
    extend S3Multipart::TransferHelpers

    attr_accessible :key, :upload_id, :name, :location, :uploader

    def execute_callback(stage, session)
      controller = S3Multipart::Uploader.deserialize(uploader)
      
      case stage
      when :begin
        controller.on_begin_callback.call(self, session)
      when :complete
        controller.on_complete_callback.call(self, session)
      end
    end

  end
end