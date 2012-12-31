S3Multipart::Engine.routes.draw do
  resources :uploads, :only => [:create, :update]
end