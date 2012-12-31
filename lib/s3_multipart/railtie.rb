if defined?(Rails)
  module S3Multipart
    class Railtie < Rails::Railtie

      initializer "s3_multipart.action_view" do 
        ActiveSupport.on_load :action_view do
          require 's3_multipart/action_view_helpers/form_helper'
        end
      end

    end
  end
end