Rails.application.routes.draw do
  mount S3Multipart::Engine => "/s3_multipart"
end
