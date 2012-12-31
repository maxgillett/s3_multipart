module S3Multipart
  module ActionViewHelpers
    module FormHelper
      def multipart_uploader_form(options = {})
        html = file_field_tag 'uploader', :accept => options[:types].join(',')
        html << button_tag(:type => 'submit', :class => 'upload-button') do
          content_tag(:strong, options[:text])
        end
      end
    end
  end
end

ActionView::Base.send :include, S3Multipart::ActionViewHelpers::FormHelper