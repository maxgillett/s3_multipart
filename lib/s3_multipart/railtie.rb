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
        Dir[Rails.root.join('app', 'uploaders', 'multipart').to_s].each do |uploader|
          require uploader
        end
      end

    end
  end
end