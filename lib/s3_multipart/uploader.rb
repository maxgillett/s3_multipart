require "s3_multipart/uploader/callbacks"
require "s3_multipart/uploader/validations"
require 'uuid'

module S3Multipart
  module Uploader

    class << self
      attr_accessor :controllers
    end

    self.controllers = {}

    # Generated multipart upload controllers (which reside in the app/uploaders/multipart
    # directory in the Rails application) inherit from this class.
    class Core

      include S3Multipart::Uploader::Callbacks
      include S3Multipart::Uploader::Validations

      def self.inherited(subclass)
        Uploader.controllers[subclass] = UUID.generate
      end

      def attach(model)
        S3Multipart::Upload.class_eval do
          has_one(model)
        end
      end

    end

  end 
end
