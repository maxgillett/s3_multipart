AWS_Config = YAML.load_file("config/aws.yml")[Rails.env]

S3Multipart.configure do |config|
  config.bucket_name   = AWS_Config['bucket']
  config.s3_access_key = AWS_Config['access_key_id']
  config.s3_secret_key = AWS_Config['secret_access_key']
  config.revision      = AWS_Config['revision']
end

