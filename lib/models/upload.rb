module S3_Multipart
  class Upload < ActiveRecord::Base
    set_table_name "s3_multipart_uploads"
    
    class << self    
      attr_accessor :callback
    end

  end
end