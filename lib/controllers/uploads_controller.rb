module S3_Multipart
  class UploadsController < ApplicationController
    def create
      begin
        response = S3_Multipart::Uploader.initiate(params)
        Upload.new(key: response[:key], upload_id: response[:id], name: response[:name])
      rescue
        response = {error: 'There was an error initiating the upload'}
      ensure
        render :json => response
      end
    end

    def put
      return complete_upload if params[:parts]
      return sign_batch if params[:content_lengths]
      return sign_part if params[:content_length]
    end 

    private 

    def sign_batch
      begin
        response = S3_Multipart::Uploader.sign_batch(params)
      rescue
        response = {error: 'There was an error in processing your upload'}
      ensure
        render :json => response
      end
    end

    def sign_part
      begin
        response = S3_Multipart::Uploader.sign_part(params)
      rescue
        response = {error: 'There was an error in processing your upload'}
      ensure
        render :json => response
      end
    end
    end

    def complete_upload
      begin
        response = S3_Multipart::Uploader.complete(params)
        
        upload = Upload.find_by_upload_id(params[:upload_id])
        upload.update_attributes(location: response[:location])
        upload.run_callback
      rescue
        response = {error: 'There was an error completing the upload'}
      ensure
        render :json => response
      end
    end

  end
end