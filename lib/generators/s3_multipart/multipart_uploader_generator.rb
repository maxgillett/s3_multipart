require 'rails/generators'

class MultipartUploaderGenerator < Rails::Generators:Base
  desc "Generates all the necessary setup for integration with the S3 Multipart gem"

  source_root File.expand_path("../templates", __FILE__)
  argument :model, :type => :string
  class_option :configuration, :type => :boolean, :default => true, :description => "Create configuration files"

  def create_uploader
    template "uploader.rb", "app/uploaders/multipart/#{file_name}_uploader.rb"
  end

  def create_migrations
    template "add_uploader_column_to_model.rb", "app/db/migrate/#{migration_time}_add_uploader_to_#{model}.rb"
    copy_file "uploads_table_migration.rb", "app/db/migrate/#{migration_time}_create_s3_multipart_uploads.rb"
  end

  def create_configuration_files
    return unless options.configuration?
    copy_file "aws.yml", "app/config/aws.yml" 
    copy_file "configuration_initializer.rb", "app/config/initializers/s3_multipart.rb"
  end

  private

    def migration_time
      Time.now.strftime("%Y%m%d%H%M%S")
    end

end