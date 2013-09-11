module S3Multipart
  module ActionViewHelpers
    module FormHelper
      def multipart_uploader_form(options = {})
        uploader = S3Multipart::Uploader
        uploader_digest = uploader.serialize(options[:uploader])

        html = file_field_tag options[:input_name], :multiple => 'multiple', :data => {:uploader => uploader_digest}
        html << options[:html].html_safe
        html << button_tag(:class => options[:button_class]) do
          content_tag(:span, options[:button_text])
        end
      end
    end
  end
end

ActionView::Base.send :include, S3Multipart::ActionViewHelpers::FormHelper
