# encoding: utf-8

# require 'active_record'
require 'xmlsimple'
require 'uuid'

module S3Multipart

  class << self

    def configure(&block)
      S3Multipart::Config.configure(block)
    end

    def remove_unfinished_uploads(seconds=60*60*24*10)
      # remove multipart uploads older than specified amt of seconds
    end

  end

  class FileTypeError < StandardError; end
  class FileSizeError < StandardError; end

end

require 's3_multipart/config'
require 's3_multipart/railtie'
require 's3_multipart/engine'
require 's3_multipart/http/net_http'
require 's3_multipart/uploader'
require 's3_multipart/transfer_helpers'
