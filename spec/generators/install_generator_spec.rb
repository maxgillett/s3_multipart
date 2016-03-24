require 'spec_helper.rb'
require_relative '../../lib/generators/s3_multipart/install_generator.rb'

describe S3Multipart::InstallGenerator, type: :generator do
  destination File.expand_path('../../../tmp', __FILE__)

  before(:all) do
    prepare_destination
    mkdir "#{destination_root}/config"
    touch "#{destination_root}/config/routes.rb"
    run_generator
  end

  it 'creates a migration for an S3 uploads table' do
    assert_migration "#{destination_root}/db/migrate/create_s3_multipart_uploads.rb"
  end

  it 'creates an AWS credential YAML configuration file' do
    assert_file 'config/aws.yml'
  end

  it 'mounts the gem engine in the app routes' do
    expect(run_generator).to match 'mount S3Multipart::Engine => "/s3_multipart"'
  end
end
