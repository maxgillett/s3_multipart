module S3Multipart
  module Uploader
    module Validations

      attr_accessor :extensions, :mime_types, :size_limits

      def accept(options)
        self.extensions = options[:extensions] 
        self.mime_types = options[:mime_types]
      end

      def limit(sizes)
        self.size_limits = sizes
      end

    end
  end 
end
