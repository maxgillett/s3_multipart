# This migration comes from s3_multipart 
class CreateS3MultipartUploads < ActiveRecord::Migration
  def change
    create_table :s3_multipart_uploads do |t|
      t.string :location
      t.string :upload_id
      t.string :key
      t.string :name
      t.string :uploader
      t.integer :size

      t.timestamps
    end
  end
end
