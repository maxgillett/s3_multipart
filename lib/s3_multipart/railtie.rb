if defined?(Rails)
  module S3Multipart

    class << self
      attr_accessor :logger
    end

    class Railtie < Rails::Railtie

      initializer "s3_multipart.action_view" do 
        ActiveSupport.on_load :action_view do
          require 's3_multipart/action_view_helpers/form_helper'
        end
      end

      initializer "s3_multipart.active_record" do
        ActiveRecord::Base.include_root_in_json = false
      end

      # Load all of the upload controllers in app/uploaders/multipart
      initializer "s3_multipart.load_upload_controllers" do
        begin
          uploaders = Dir.entries(Rails.root.join('app', 'uploaders', 'multipart').to_s).keep_if {|n| n =~ /uploader\.rb$/}
          uploaders.each do |uploader|
            require "#{Rails.root.join('app', 'uploaders', 'multipart')}/#{uploader}"
          end
        rescue
          # Give some sort of error in the console
        end
      end

      initializer "rails logger" do
        S3Multipart.logger = Rails.logger
      end

    end
  end
end
