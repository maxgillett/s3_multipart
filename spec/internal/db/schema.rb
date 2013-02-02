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
    t.string   "name"
    t.integer  "upload_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  create_table "users", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end
end
