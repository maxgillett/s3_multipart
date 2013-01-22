ActiveRecord::Schema.define do
  create_table("s3_multipart_uploads", :force => true) do |t|
    t.string   "location"
    t.string   "upload_id"
    t.string   "key"
    t.string   "name"
    t.string   "uploader"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end
  create_table "videos", :force => true do |t|
    t.integer  "upload_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end
