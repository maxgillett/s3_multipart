# encoding: utf-8

# require 'active_record'
require 'xmlsimple'
require 'uuid'

module S3Multipart

  class << self

    def configure(&block)
      S3Multipart::Uploader::Config.configure(block)
    end

    def remove_unfinished_uploads(seconds=60*60*24*10)
      # remove multipart uploads older than specified amt of seconds
    end

  end

  # module ActionControllerHelpers

  #   module AttachUploader
  #     def self.on_begin(&block)
  #       S3Multipart::Upload.class_eval do
  #         self.on_begin_callback = block
  #         def on_begin
  #           Upload.on_begin_callback.call(self)
  #         end
  #       end
  #     end

  #     def self.on_complete(&block)
  #       S3Multipart::Upload.class_eval do
  #         self.on_complete_callback = block
  #         def on_complete
  #           Upload.on_complete_callback.call(self)
  #         end
  #       end
  #     end 
  #   end

  #   def attach_uploader
  #     return AttachUploader
  #   end

  # end

end

require 's3_multipart/railtie'
require 's3_multipart/engine'
require 's3_multipart/http/net_http'
require 's3_multipart/uploader'
require 's3_multipart/uploader/config'
require 's3_multipart/transfer_helpers'

# ActionController::Base.send(:include, S3Multipart::ActionControllerHelpers)