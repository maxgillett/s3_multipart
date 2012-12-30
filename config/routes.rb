S3_Multipart::Engine.routes.draw do
  map.resources :uploads, :only => [ :create, :put ],
                          :controller => "uploads",
                          :path_prefix => mount_at
end