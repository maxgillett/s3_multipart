require 'rubygems'
require 'bundler'

Bundler.require :development

require 'capybara/rspec'

Combustion.initialize! 

require 'rspec/rails'
require 'capybara/rails'

RSpec.configure do |config|
  #config.use_transactional_fixtures = true
end

class S3Response
  class << self
    def success
      response_body(
        %{<PostResponse>
          <Key>2f020fj20fj</Key>
          <UploadId>fj2foj20f22</UploadId>
        </PostResponse>}
      )
    end

    def upload_not_found
      response_body(
        %{<PostResponse>
          <Message>The specified upload does not exist. The upload ID may be invalid, or the upload may have been aborted or completed.</Message>
        </PostResponse>}
      )
    end

    def response_body(body)
      OpenStruct.new({ body: body })
    end
  end
  private_class_method :response_body
end
