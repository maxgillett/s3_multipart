require 'rails/generators'

module S3Multipart
  class MultipartUploaderGenerator < Rails::Generators::Base
    desc "Generates all the necessary setup for integration with the S3 Multipart gem"

    source_root File.expand_path("../templates", __FILE__)
    argument :model, :type => :string
    class_option :migrations, :type => :boolean, :default => true, :description => "Create migration files"

    def create_uploader
      empty_directory("app/uploaders")
      empty_directory("app/uploaders/multipart")
      template "uploader.rb", "app/uploaders/multipart/#{model}_uploader.rb"
    end

    def create_migrations
      return unless options.migrations?
      template "add_uploader_column_to_model.rb", "db/migrate/#{migration_time}_add_uploader_to_#{model}.rb"
      copy_file "uploads_table_migration.rb", "db/migrate/#{migration_time}_create_s3_multipart_uploads.rb"
    end

    def create_configuration_files
      copy_file "aws.yml", "app/config/aws.yml" 
      copy_file "configuration_initializer.rb", "app/config/initializers/s3_multipart.rb"
    end

    private

      def migration_time
        Time.now.strftime("%Y%m%d%H%M%S")
      end

      def model_constant
        model.split("_").map(&:capitalize).join()
      end

  end
end