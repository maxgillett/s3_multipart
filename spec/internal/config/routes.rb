Rails.application.routes.draw do
  match 'upload', to: 'pages#upload'
  mount S3Multipart::Engine => "/s3_multipart"
end
