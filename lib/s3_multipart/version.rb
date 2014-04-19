module S3Multipart
  VERSION = "0.0.10.5"
  BREAKING_CHANGES = {
    :"0.0.10.2" => 'Modifications made to the database table used by the gem are now handled by migrations. If you are upgrading versions, run `rails g s3_multipart:install_new_migrations` followed by `rake db:migrate`. Fresh installs do not require subsequent migrations. The current version must now also be passed in to the gem\'s configuration function to alert you of breaking changes. This is done by setting a revision yml variable. See the section regarding the aws.yml file in the readme section below (just before "Getting Started").'
  }
end
