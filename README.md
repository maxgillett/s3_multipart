# S3 Multipart

The S3 Multipart gem brings direct multipart uploading to S3 to Rails. Data is piped from the client straight to Amazon S3 and a callback is run when the upload is complete.

Multipart uploading allows files to be split into many chunks and uploaded in parallel or succession (or both). This can result in dramatically increased upload speeds for the client and allows for the pausing and resuming of uploads. For a more complete overview of multipart uploading as it applies to S3, see the overview [here](http://docs.amazonwebservices.com/AmazonS3/latest/dev/mpuoverview.html). 

## Setup

Install the gem

```bash
gem install s3_multipart
```

Install the included migrations. This will create a table in your database to track initiated and completed uploads

```bash
rake s3_multipart:install:migrations
```

Add the following to your routes file:

```ruby
mount S3Multipart::Engine => "/s3_multipart"
```

And if you are using sprockets, add the following to your application.js file

```ruby
//= require s3_multipart/s3_multipart
```

Finally, create an initializer in config/initializers with the following, adding in your credentials.

```ruby
S3Multipart.configure do |config|
  config.bucket_name   = '#########'
  config.s3_access_key = '#########'
  config.s3_secret_key = '#########'
end
```ruby

## Getting Started

S3_Multipart comes with two helper functions required in integrating uploads into your application.

The `attach_uploader` function is available in your controllers. Call it from within a routed method, and pass in a block of code to be executed when the upload has completed successfully. The completed upload object has `location`, `upload_id`, `name`, and `key` attributes that can be accessed and manipulated. 

```ruby
def your_controller_method
  attach_uploader do |upload|
    # your code here
  end
end
```

The `multipart_uploader_form` function is a view helper, and generates the necessary input elements.

```ruby
<%= multipart_uploader_form(types: ['video/mpeg'], text: 'Select a Video') %>
```

puts out this:

```html
<input accept="video/mpeg" id="uploader" name="uploader" type="file">
<button class="upload-button" type="submit"><strong>Select a Video</strong></button>
```

## Contributing
