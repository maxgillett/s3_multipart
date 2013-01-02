# encoding: utf-8

require 'active_record'
require 'xmlsimple'
require 'uuid'

module S3Multipart

  class << self

    # Syntax:
    #
    # S3_Multipart.configure do |config|
    #   config.s3_access_key = ''
    #   config.s3_secret_key = ''
    #   config.bucket_name   = ''
    # end
    def configure(&block)
      S3Multipart::Uploader::Config.configure(block)
    end

    def remove_unfinished_uploads(seconds=60*60*24*10)
      # remove multipart uploads older than specified amt of seconds
    end

  end

  module ActionControllerHelpers

    #
    # Stores a code block in the Upload class that will be executed (and passed the
    # completed upload object) when the on_complete method is called on an 
    # instance of the Upload class
    #
    def attach_uploader(&block)
      S3Multipart::Upload.class_eval do
        self.on_complete_callback = block
        def on_complete
          Upload.on_complete_callback.call(self)
        end
      end
    end

  end

end

require 's3_multipart/railtie'
require 's3_multipart/engine'
require 's3_multipart/http/net_http'
require 's3_multipart/uploader'
require 's3_multipart/uploader/config'


ActionController::Base.send(:include, S3Multipart::ActionControllerHelpers)