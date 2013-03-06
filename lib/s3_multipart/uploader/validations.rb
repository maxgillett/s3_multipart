module S3Multipart
  module Uploader
    module Validations

      attr_accessor :file_types, :size_limits

      def accept(types)
        self.file_types = types         
      end

      def limit(sizes)
        self.size_limits = sizes
      end

    end
  end 
end
