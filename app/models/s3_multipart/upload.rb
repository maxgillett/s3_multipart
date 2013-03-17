module S3Multipart
  class Upload < ::ActiveRecord::Base
    extend S3Multipart::TransferHelpers

    attr_accessible :key, :upload_id, :name, :location, :uploader, :size
    before_create :validate_file_type, :validate_file_size

    def self.create(params)
      response = initiate(params)
      super(key: response["key"], upload_id: response["upload_id"], name: response["name"], uploader: params["uploader"], size: params["content_size"])
    end

    def execute_callback(stage, session)
      controller = deserialize(uploader)
      
      case stage
      when :begin
        controller.on_begin_callback.call(self, session) if controller.on_begin_callback
      when :complete
        controller.on_complete_callback.call(self, session) if controller.on_begin_callback
      end
    end

    private

      def validate_file_size
        size = self.size
        limits = deserialize(self.uploader).size_limits
        raise FileSizeError, "File size is too small" if limits[:min] > size
        raise FileSizeError, "File size is too large" if limits[:max] < size 
      end

      def validate_file_type
        ext = self.name.match(/\.([a-zA-Z0-9]+)$/)[1]
        controller = deserialize(self.uploader)

        if !controller.file_types.include?(ext)
          raise FileTypeError, "File type not supported"
        end
      end

      def deserialize(uploader)
        S3Multipart::Uploader.deserialize(uploader)
      end

  end
end
