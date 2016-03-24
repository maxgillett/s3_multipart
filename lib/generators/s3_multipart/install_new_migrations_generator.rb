require_relative 'migration_existence_validation_helper.rb'
require 'rails/generators'

module S3Multipart
  class InstallNewMigrationsGenerator < Rails::Generators::Base
    include MigrationExistenceValidationHelper

    desc "Generates the migrations necessary when updating the gem to the latest version"

    source_root File.expand_path("../templates", __FILE__)

    def create_latest_migrations
      prompt_if_exists for_file: size_column_migration_name, to_execute: ->{
        copy_file "#{size_column_migration_name}.rb", "db/migrate/#{migration_time}_#{size_column_migration_name}.rb"
      }

      prompt_if_exists for_file: context_column_migration_name, to_execute: ->{
        copy_file "#{context_column_migration_name}.rb", "db/migrate/#{migration_time}_#{context_column_migration_name}.rb"
      }
    end

    private

      def migration_time
        Time.now.strftime("%Y%m%d%H%M%S")
      end

      def size_column_migration_name
        'add_size_to_s3_multipart_uploads'
      end

      def context_column_migration_name
        'add_context_to_s3_multipart_uploads'
      end
  end
end
