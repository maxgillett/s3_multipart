require_relative 'migration_existence_validation_helper.rb'
require 'rails/generators'

module S3Multipart
  class InstallGenerator < Rails::Generators::Base
    include MigrationExistenceValidationHelper

    desc "Generates all the necessary setup for integration with the S3 Multipart gem"

    source_root File.expand_path("../templates", __FILE__)

    def create_migrations
      prompt_if_exists for_file: migration_name, to_execute: ->{
        copy_file "uploads_table_migration.rb", "db/migrate/#{migration_time}_#{migration_name}.rb"
      }
    end

    def create_configuration_files
      copy_file "aws.yml", "config/aws.yml"
      copy_file "configuration_initializer.rb", "config/initializers/s3_multipart.rb"
      route 'mount S3Multipart::Engine => "/s3_multipart"'
    end

    private

      def migration_name
        'create_s3_multipart_uploads'
      end

      def migration_time
        Time.now.strftime("%Y%m%d%H%M%S")
      end

      def model_constant
        model.split("_").map(&:capitalize).join()
      end
  end
end
