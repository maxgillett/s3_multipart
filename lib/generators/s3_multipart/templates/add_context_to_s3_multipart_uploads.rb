class AddContextToS3MultipartUploads < ActiveRecord::Migration
  def change
    add_column :s3_multipart_uploads, :context, :text
  end
end

