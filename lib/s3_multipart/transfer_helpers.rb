module S3Multipart

  # Collection of methods to be mixed in to the Upload class.  
  # Handle all communication with Amazon S3 servers
  module TransferHelpers

    def initiate(options)
      url = "/#{unique_name(options)}?uploads"

      headers = {content_type: options[:content_type]}
      headers.merge!(options[:headers]) if options.key?(:headers)
      headers[:authorization], headers[:date] = sign_request verb: 'POST',
                                                             url: url,
                                                             content_type: options[:content_type],
                                                             headers: options[:headers]

      response = Http.post url, headers: headers
      parsed_response_body = XmlSimple.xml_in(response.body)  

      { "key"  => parsed_response_body["Key"][0],
        "upload_id"   => parsed_response_body["UploadId"][0],
        "name" => options[:object_name] }
    end

    def sign_batch(options)
      parts = options[:content_lengths].to_s.split('-').each_with_index.map do |len, i|
        sign_part(options.merge!({content_length: len, part_number: i+1}))
      end
    end

    def sign_part(options)
      url = "/#{options[:object_name]}?partNumber=#{options[:part_number]}&uploadId=#{options[:upload_id]}"
      authorization, date = sign_request verb: 'PUT', url: URI.escape(url), content_length: options[:content_length]
      
      { authorization: authorization, date: date }
    end

    def complete(options)
      options[:content_type] = "application/xml"

      url = URI.escape("/#{options[:object_name]}?uploadId=#{options[:upload_id]}")
      
      body = format_part_list_in_xml(options)
      headers = { content_type: options[:content_type],
                  content_length: options[:content_length] }

      headers[:authorization], headers[:date] = sign_request verb: 'POST', url: url, content_type: options[:content_type]

      response = Http.post url, {headers: headers, body: body}
      parsed_response_body = XmlSimple.xml_in(response.body)  

      begin
        return { location: parsed_response_body["Location"][0] }
      rescue NoMethodError
        return { error: "Upload does not exist"} if parsed_response_body["Message"].first.match("The specified upload does not exist. The upload ID may be invalid, or the upload may have been aborted or completed.")
      end
    end

    def sign_request(options)
      time = Time.now.utc.strftime("%a, %d %b %Y %T %Z")
      [calculate_authorization_hash(time, options), time]
    end

    def unique_name(options)
      url = [UUID.generate, options[:object_name]].join("/")
      controller = S3Multipart::Uploader.deserialize(options[:uploader])

      if controller.mount_point && defined?(CarrierWaveDirect)
        uploader = controller.model.to_s.classify.constantize.new.send(controller.mount_point)

        if uploader.class.ancestors.include?(CarrierWaveDirect::Uploader)
          url = uploader.key.sub(/#{Regexp.escape(CarrierWaveDirect::Uploader::FILENAME_WILDCARD)}\z/, options[:object_name])
        end
      end

      URI.escape(url)
    end

    private

      def calculate_authorization_hash(time, options)
        date = String.new(time)
        request_parts = [ options[:verb],
                       "", # optional content md5
                       options[:content_type]]

        headers = options[:headers] || {}

        if from_upload_part?(options) && options[:parts].nil?
          request_parts << "" # skip date as it's present as an x-amz- header
          headers["x-amz-date"] = date
        else
          request_parts << date
        end

        if headers.present?
          canonicalized_headers = headers.keys.sort.inject([]) {|array,k| array.push "#{k}:#{headers[k]}"}.join("\n")
          request_parts << canonicalized_headers
        end

        request_parts << "/#{Config.instance.bucket_name}#{options[:url]}"
        unsigned_request = request_parts.join("\n")
        signature = Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', Config.instance.s3_secret_key, unsigned_request))
        
        authorization = "AWS" + " " + Config.instance.s3_access_key + ":" + signature
      end

      def from_upload_part?(options)
        options[:content_length].to_s.match(/^[0-9]+$/) ? true : false
      end

      def format_part_list_in_xml(options)
        hash = Hash["Part", ""];
        hash["Part"] = options[:parts].map do |part| 
          { "PartNumber" => part[:partNum], "ETag" => part[:ETag] }
        end
        hash["Part"].sort_by! {|obj| obj["PartNumber"]}

        XmlSimple.xml_out(hash, { :RootName => "CompleteMultipartUpload", :AttrPrefix => true })
      end

    end

end
