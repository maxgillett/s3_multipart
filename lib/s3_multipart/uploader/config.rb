module S3_Multipart
  module Uploader
    class Config
      include Singleton
      attr_reader :s3_access_key, :s3_secret_key, :bucket_name

      def self.configure(&block)
        block.call(self.instance)
      end
    end
  end
end