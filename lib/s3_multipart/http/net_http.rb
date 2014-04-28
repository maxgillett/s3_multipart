module S3Multipart
  class Http
    require 'net/http'

    attr_accessor :method, :path, :body, :headers, :response

    def initialize(method, path, options)
      @method = method
      @path = path
      @headers = options[:headers]
      @body = options[:body]
    end

    class << self
      def get(path, options={})
        new(:get, path, options).perform
      end

      def post(path, options={})
        new(:post, path, options).perform
      end

      def put(path, options={})
        new(:put, path, options).perform
      end
    end

    def perform
      request = request_class.new(path)
      headers.each do |key, val|
        request[key.to_s.split("_").map(&:capitalize).join("-")] = val
      end
      request.body = body if body

      @response = http.request(request)
    end

    private

      def http 
        Net::HTTP.new("#{Config.instance.bucket_name}.s3.amazonaws.com", 80)
      end

      def request_class
        Net::HTTP.const_get(method.to_s.capitalize)
      end

  end
end
