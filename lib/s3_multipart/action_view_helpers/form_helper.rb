module S3Multipart
  module ActionViewHelpers
    module FormHelper
      def multipart_uploader_form(options = {})
        uploader_digest = S3Multipart::Uploader.serialize(options[:uploader])
        if options[:types] == nil
          options[:types] = options[:uploader].constantize.file_types.map { |t| ".#{t}" }
        end
        html = file_field_tag options[:input_name], :accept => options[:types].join(','), :multiple => 'multiple', :data => {:uploader => uploader_digest}
        html << options[:html].html_safe
        html << button_tag(:class => options[:button_class]) do
          content_tag(:span, options[:button_text])
        end
      end
    end
  end
end

ActionView::Base.send :include, S3Multipart::ActionViewHelpers::FormHelper