module S3_Multipart
  module ActionViewHelpers
    module FormHelper
      def multipart_uploader_form(options = {})
        file_field_tag 'uploader', :accept => options[:types].join(',')
        button_tag(:type => 'button', :class => 'upload-button') do
          content_tag(:strong, 'Upload')
        end
      end
    end
  end
end