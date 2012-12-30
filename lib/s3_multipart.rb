# encoding: utf-8

require 'active_record'
require 'uuid'

module S3_Multipart

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

  module ActiveRecord

    # Needs to be reworked to allow for different callbacks to be called for several upload forms
    def attach_uploader(&block)
      Upload.class_eval do
        self.callback = block
        def run_callback
          callback.call(self)
        end
      end
    end

  end

end

require 's3_multipart/uploader'
require 's3_multipart/railtie'
require 's3_multipart/engine'

ActiveRecord::Base.extend S3_Multipart::ActiveRecord
ActionView::Base.send :include, S3_Multipart::ActionViewHelpers::FormHelper