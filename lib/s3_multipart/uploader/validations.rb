module S3Multipart
  module Uploader
    module Validations

      attr_accessor :file_types

      def accept(types)
        self.file_types = types         
      end

    end
  end 
end
