if defined?(Rails)
  module S3Multipart
    class Railtie < Rails::Railtie

      initializer "s3_multipart.action_view" do 
        ActiveSupport.on_load :action_view do
          require 's3_multipart/action_view_helpers/form_helper'
        end
      end

      # Load all of the upload controllers in app/uploaders/multipart
      initializer "s3_multipart.load_upload_controllers" do
        uploaders = Dir.entries(Rails.root.join('app', 'uploaders', 'multipart').to_s).keep_if {|n| n =~ /[uploader]/}
        uploaders.each do |uploader|
          require "#{Rails.root.join('app', 'uploaders', 'multipart')}/#{uploader}"
        end
      end

    end
  end
end