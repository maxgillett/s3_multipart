module S3Multipart
  class Upload < ::ActiveRecord::Base
    extend S3Multipart::TransferHelpers
    include ActionView::Helpers::NumberHelper

    before_create :validate_file_type, :validate_file_size

    def self.create(params)
      response = initiate(params)
      super(key: response["key"], upload_id: response["upload_id"], name: response["name"], uploader: params["uploader"], size: params["content_size"], context: params["context"].to_s)
    end

    def execute_callback(stage, session)
      controller = deserialize(uploader)

      case stage
      when :begin
        controller.on_begin_callback.call(self, session) if controller.on_begin_callback
      when :complete
        controller.on_complete_callback.call(self, session) if controller.on_complete_callback
      end
    end

    private

      def validate_file_size
        size = self.size
        limits = deserialize(self.uploader).size_limits

        if limits.present?
          if limits.key?(:min) && limits[:min] > size
            raise FileSizeError, I18n.t("s3_multipart.errors.limits.min", min: number_to_human_size(limits[:min]))
          end

          if limits.key?(:max) && limits[:max] < size
            raise FileSizeError, I18n.t("s3_multipart.errors.limits.max", max: number_to_human_size(limits[:max]))
          end
        end
      end

      def validate_file_type
        ext = self.name.match(/\.([a-zA-Z0-9]+)$/)[1]
        types = deserialize(self.uploader).file_types

        unless types.blank? || types.include?(ext)
          raise FileTypeError, I18n.t("s3_multipart.errors.types", types: types.join(", "))
        end
      end

      def deserialize(uploader)
        S3Multipart::Uploader.deserialize(uploader)
      end

  end
end
