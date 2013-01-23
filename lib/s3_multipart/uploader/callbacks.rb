module S3Multipart
  module Uploader
    module Callbacks

      attr_accessor :on_begin_callback, :on_complete_callback

      def on_begin(&block)
        self.on_begin_callback = block
      end

      def on_complete(&block)
        self.on_complete_callback = block
      end

    end
  end 
end