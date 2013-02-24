module S3Multipart
  class Upload < ::ActiveRecord::Base
    extend S3Multipart::TransferHelpers

    attr_accessible :key, :upload_id, :name, :location, :uploader
    before_create :validate_mime_types

    def self.create(params)
      response = initiate(params)
      super(key: response["key"], upload_id: response["upload_id"], name: response["name"], uploader: params["uploader"])
    end

    def execute_callback(stage, session)
      controller = deserialize(uploader)
      
      case stage
      when :begin
        controller.on_begin_callback.call(self, session)
      when :complete
        controller.on_complete_callback.call(self, session)
      end
    end

    private

      def validate_mime_types(upload)
        ext = upload.name.match(/\.([a-zA-Z0-9]+)$/)[1]
        controller = deserialize(uploader)

        if !controller.file_types.include?(ext)
          return false
        end
      end

      def deserialize(uploader)
        S3Multipart::Uploader.deserialize(uploader)
      end

  end
end
