class AddSizeToS3MultipartUploads < ActiveRecord::Migration
  def change
    add_column :s3_multipart_uploads, :size, :integer
  end
end
