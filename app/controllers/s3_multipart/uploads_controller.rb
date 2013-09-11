require "securerandom"

module S3Multipart
  class UploadsController < ApplicationController
  
    def create
      begin
        upload = Upload.create(params)
        upload.execute_callback(:begin, session)
        response = upload.to_json
      rescue FileTypeError, FileSizeError => e
        response = {error: e.message}
      rescue => e
        e_id = handle_error(e)
        response = {error: "There was an error initiating the upload. Error ID: #{e_id}"}
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
        rescue => e
          e_id = handle_error(e)
          response = {error: "There was an error in processing your upload. Error ID: #{e_id}"}
        ensure
          render :json => response
        end
      end

      def sign_part
        begin
          response = Upload.sign_part(params)
        rescue => e
          e_id = handle_error(e)
          response = {error: "There was an error in processing your upload. Error ID: #{e_id}"}
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
        rescue => e
          e_id = handle_error(e)
          response = {error: "There was an error completing your upload. Error ID: #{e_id}"}
        ensure
          render :json => response
        end
      end

      def handle_error(e)
        e_id = SecureRandom.uuid 
        S3Multipart.logger.debug e_id
        S3Multipart.logger.debug e
        S3Multipart.logger.debug e.backtrace
      end

  end
end
