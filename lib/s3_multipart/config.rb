require 'singleton'

module S3Multipart
  class Config
    include Singleton
    attr_accessor :s3_access_key, :s3_secret_key, :bucket_name, :revision

    def self.configure(block)
      block.call(self.instance)
      check_for_breaking_changes
    end

    def self.check_for_breaking_changes
      if self.instance.revision != VERSION 
        raise ArgumentError, "Breaking changes were made to the S3_Multipart gem:\n #{BREAKING_CHANGES[VERSION.to_sym]}\n See the Readme for additional information."
      end
    end
  end
end
