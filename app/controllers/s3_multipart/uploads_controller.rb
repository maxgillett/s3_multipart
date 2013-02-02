module S3Multipart
  class UploadsController < ApplicationController
    def create
      begin
        response = Upload.initiate(params)
        upload = Upload.create(key: response["key"], upload_id: response["upload_id"], name: response["name"], uploader: params["uploader"])
        response["id"] = upload["id"]
        upload.execute_callback(:begin, session)
      rescue
        response = {error: 'There was an error initiating the upload'}
      ensure
        render :json => response
      end
    end

    def update
      return complete_upload if params[:parts]
      return sign_batch if params[:content_lengths]
      return sign_part if params[:content_length]
    end 

    private 

      def sign_batch
        begin
          response = Upload.sign_batch(params)
        rescue
          response = {error: 'There was an error in processing your upload'}
        ensure
          render :json => response
        end
      end

      def sign_part
        begin
          response = Upload.sign_part(params)
        rescue
          response = {error: 'There was an error in processing your upload'}
        ensure
          render :json => response
        end
      end

      def complete_upload
        begin
          response = Upload.complete(params)
          upload = Upload.find_by_upload_id(params[:upload_id])
          upload.update_attributes(location: response[:location])
          upload.execute_callback(:complete, session)
        rescue
          response = {error: 'There was an error completing the upload'}
        ensure
          render :json => response
        end
      end

  end
end