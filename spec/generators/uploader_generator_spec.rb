require 'spec_helper.rb'
require_relative '../../lib/generators/s3_multipart/uploader_generator.rb'

describe S3Multipart::UploaderGenerator, type: :generator do
  destination File.expand_path('../../../tmp', __FILE__)
  arguments %w(foo)

  before(:all) do
    prepare_destination
    mkdir "#{destination_root}/app"
    run_generator
  end

  it 'creates a migration to add an uploader column to the specified model table' do
    assert_migration "#{destination_root}/db/migrate/add_uploader_to_foo.rb"
  end

  it 'creates an uploaders folder' do
    assert_directory "#{destination_root}/app/uploaders"
  end

  it 'creates a multipart folder in the uploaders folder' do
    assert_directory "#{destination_root}/app/uploaders/multipart"
  end

  it 'adds an uploader for the specified model in the uploaders multipart folder' do
    assert_file "#{destination_root}/app/uploaders/multipart/foo_uploader.rb"
  end
end
