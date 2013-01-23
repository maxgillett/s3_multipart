Rails.application.routes.draw do
  root to: 'pages#upload'
  mount S3Multipart::Engine => "/s3_multipart"
end
