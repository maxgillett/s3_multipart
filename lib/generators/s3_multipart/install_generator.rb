require 'rails/generators'

module S3Multipart
  class InstallGenerator < Rails::Generators::Base
    desc "Generates all the necessary setup for integration with the S3 Multipart gem"

    source_root File.expand_path("../templates", __FILE__)

    def create_migrations
      copy_file "uploads_table_migration.rb", "db/migrate/#{migration_time}_create_s3_multipart_uploads.rb"
    end

    def create_configuration_files
      copy_file "aws.yml", "config/aws.yml"
      copy_file "configuration_initializer.rb", "config/initializers/s3_multipart.rb"
      route 'mount S3Multipart::Engine => "/s3_multipart"'
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
