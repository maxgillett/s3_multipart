require 'rubygems'
require 'bundler'

Bundler.require :development

require 'capybara/rspec'

Combustion.initialize! 

require 'rspec/rails'
require 'capybara/rails'

# Engine config initializer
require 'setup_credentials.rb'

RSpec.configure do |config|
  #config.use_transactional_fixtures = true
end