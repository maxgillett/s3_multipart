require 'spec_helper.rb'
require_relative '../../lib/generators/s3_multipart/install_new_migrations_generator.rb'

describe S3Multipart::InstallNewMigrationsGenerator, type: :generator do
  destination File.expand_path('../../../tmp', __FILE__)

  before(:all) do
    prepare_destination
    run_generator
  end

  it 'creates a migration to add a size column to the S3 uploads table' do
    migration_exists = !!Dir["#{destination_root}/db/migrate/*_add_size_to_s3_multipart_uploads.rb"].length
    expect(migration_exists).to be_true
  end

  it 'creates a migration to add a context column to the S3 uploads table' do
    migration_exists = !!Dir["#{destination_root}/db/migrate/*_add_context_to_s3_multipart_uploads.rb"].length
    expect(migration_exists).to be_true
  end
end
