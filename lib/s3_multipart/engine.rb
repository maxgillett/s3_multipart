module S3_Multipart
  class Engine < Rails::Engine
    config.mount_at = '/'

    paths["app/models"] = "lib/models"
    paths["app/controllers"] = "lib/controllers"
  end
end