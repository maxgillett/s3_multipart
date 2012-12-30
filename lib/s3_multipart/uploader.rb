require 'uploader/config'
require "xmlsimple"

require 'uploader/config'

module S3_Multipart
  module Uploader
    def initiate(options)
      url = "/#{options[:object_name]}?uploads"

      headers = {content_type: options[:content_type]}
      headers[:authorization], headers[:date] = sign_request verb: 'POST', url: url, content_type: options[:content_type]

      response = Http.post url, headers
      parsed_response_body = XmlSimple.xml_in(response.body)  
    
      return { "key"  => parsed_response["Key"][0],
               "id"   => parsed_response["UploadId"][0],
               "name" => object_name }
    end

    def sign_batch(options)
      parts = options[:content_lengths].split('-').each_with_index.map do |len, i|
        sign_part(options.merge!({content_length: len, part_number: i+1}))
      end
    end

    def sign_part(options)
      url = "/#{options[:object_name]}?partNumber=#{options[:part_number]}&uploadId=#{options[:upload_id]}"
      authorization, date = sign_request verb: 'PUT', url: url, content_length: options[:content_length]
      
      return {authorization: authorization, date: date}
    end

    def complete(options)
      url = "/#{options[:object_name]}?uploadId=#{options[:upload_id]}"

      headers = { content_type: options[:content_type],
                  content_length: options[:content_length],
                  body: format_part_list_in_xml(options) }
                
      headers[:authorization], headers[:date] = sign_request verb: 'POST', url: url, content_type: 'application/xml'

      response = Http.post url, headers
      parsed_response_body = XmlSimple.xml_in(response.body)  

      return { "location"  => parsed_response["Location"][0] }
    end

    def sign_request(options)
      options.default = ""
      time = Time.now.strftime("%a, %d %b %Y %T %Z")

      return [signed_request(time, options), Time]
    end

    private

    def calculate_authorization_hash(time, options)
      date = String.new(time).insert(0, "\nx-amz-date:") if from_upload_part?(options)
      unsigned_request = "#{options[:verb]}\n#{options[:content_md5]}\n#{options[:content_type]}\n#{date}\n/#{Config.bucket_name}#{options[:url]}" 
      signature = Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', Config.s3_secret_key, unsigned_request))
      
      authorization = "AWS" + " " + Config.s3_access_key + ":" + signature
    end

    def from_upload_part?(options)
      options[:content_length] =~ /^[0-9]+$/ ? true : false
    end

    def format_part_list_in_xml(options)
      hash = Hash["Part", ""];
      hash["Part"] = options[:parts].map do |part| 
        { "PartNumber" => part["partNum"], "ETag" => part["ETag"] }
      end
      hash["Part"].sort_by! {|obj| obj["PartNumber"]}

      XmlSimple.xml_out(hash, { :RootName => "CompleteMultipartUpload", :AttrPrefix => true })
    end
  end
end
