require "s3_multipart/uploader/callbacks"
require "s3_multipart/uploader/validations"
require 'active_support/core_ext/string'
require "digest/sha1"

module S3Multipart
  module Uploader

    class << self
      attr_accessor :controllers
    end

    self.controllers = {}

    def self.serialize(controller)
      controllers[controller.to_s.to_sym]
    end

    def self.deserialize(digest)
      controllers.key(digest).to_s.constantize
    end

    # Generated multipart upload controllers (which reside in the app/uploaders/multipart
    # directory in the Rails application) extend this module.
    module Core

      include S3Multipart::Uploader::Callbacks
      include S3Multipart::Uploader::Validations

      def self.extended(klass)
        Uploader.controllers[klass.to_s.to_sym] = Digest::SHA1.hexdigest(klass.to_s)
      end

      def attach(model)
        S3Multipart::Upload.class_eval do
          has_one(model)
        end
      end

    end

  end 
end
