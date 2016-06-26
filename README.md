# S3 Multipart
[![Gem Version](https://badge.fury.io/rb/s3_multipart.svg)](http://badge.fury.io/rb/s3_multipart)

The S3 Multipart gem brings direct multipart uploading to S3 to Rails. Data is piped from the client straight to Amazon S3 and a server-side callback is run when the upload is complete.

Multipart uploading allows files to be split into many chunks and uploaded in parallel or succession (or both). This can result in dramatically increased upload speeds for the client and allows for the pausing and resuming of uploads. For a more complete overview of multipart uploading as it applies to S3, see the documentation [here](http://docs.amazonwebservices.com/AmazonS3/latest/dev/mpuoverview.html). Read more about the philosophy behind the gem on the Bitcast [blog](http://blog.bitcast.io/post/43001057745/direct-multipart-uploads-to-s3-in-rails).

## What's New

**0.0.10.6** - See pull request [23](https://github.com/maxgillett/s3_multipart/pull/23) for detailed changes. Changes will be documented in README soon.

**0.0.10.5** - See pull request [16](https://github.com/maxgillett/s3_multipart/pull/16) and [18](https://github.com/maxgillett/s3_multipart/pull/18) for detailed changes. 

**0.0.10.4** - Fixed a race condition that led to incorrect upload progress feedback.

**0.0.10.3** - Fixed a bug that prevented 5-10mb files from being uploaded correctly.

**0.0.10.2** - Modifications made to the database table used by the gem are now handled by migrations. If you are upgrading versions, run `rails g s3_multipart:install_new_migrations` followed by `rake db:migrate`. Fresh installs do not require subsequent migrations. The current version must now also be passed in to the gem's configuration function to alert you of breaking changes. This is done by setting a revision yml variable. See the section regarding the aws.yml file in the readme section below (just before "Getting Started").

**0.0.9** - File type and size validations are now specified in the upload controller. Untested support for browsers that lack the FileBlob API

## Setup

First, assuming that you already have an S3 bucket set up, you will need to paste the following into your CORS configuration file, located under the permissions tab in your S3 console.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
        <AllowedOrigin>*</AllowedOrigin>
        <AllowedMethod>PUT</AllowedMethod>
        <AllowedMethod>GET</AllowedMethod>
        <MaxAgeSeconds>3000</MaxAgeSeconds>
        <ExposeHeader>ETag</ExposeHeader>
        <AllowedHeader>Authorization</AllowedHeader>
        <AllowedHeader>Content-Type</AllowedHeader>
        <AllowedHeader>Content-Length</AllowedHeader>
        <AllowedHeader>x-amz-date</AllowedHeader>
        <AllowedHeader>origin</AllowedHeader>
        <AllowedHeader>Access-Control-Expose-Headers</AllowedHeader>
    </CORSRule>
</CORSConfiguration>
```

Next, install the gem, and add it to your gemfile. 

```bash
gem install s3_multipart
```

Run the included generator to create the required migrations and configuration files. Make sure to migrate after performing this step.

```bash
rails g s3_multipart:install
```

If you are using sprockets, add the following to your application.js file. Make sure that the latest underscore and jQuery libraries have been required before this line. Lodash is not supported at this time.

```js
//= require s3_multipart/lib
```

Also in your application.js file you will need to include the following:

```javascript
$(function() {
  $(".submit-button").click(function() { // The button class passed into multipart_uploader_form (see "Getting Started")
    new window.S3MP({
      bucket: "YOUR_S3_BUCKET",
      fileInputElement: "#uploader",
      fileList: [], // An array of files to be uploaded (see "Getting Started")
      onStart: function(upload) {
        console.log("File %d has started uploading", upload.key)
      },
      onComplete: function(upload) {
        console.log("File %d successfully uploaded", upload.key)
      },
      onPause: function(key) {
        console.log("File %d has been paused", key)
      },
      onCancel: function(key) {
        console.log("File upload %d was canceled", key)
      },
      onError: function(err) {
        console.log("There was an error")
      },
      onProgress: function(num, size, done, percent, speed) {
        console.log("File %d is %f percent done (%f of %f total) and uploading at %s", num, percent, done, size, speed);
      }
    });
  });
});
```

This piece of code does some configuration and provides various callbacks that you can hook into. It will be discussed further at the end of the Getting Started guide below.

Finally, edit the aws.yml that was created in your config folder with the correct credentials for each environment. Set the revision number to the current version number. If breaking changes are made to the gem in a later version, then you will be notified when the two versions do not match in the log.

```yaml
development:
  access_key_id: ""
  secret_access_key: ""
  bucket: ""
  revision: "#.#.#"
```

## Getting Started

S3_Multipart comes with a generator to set up your upload controllers. Running

```bash
rails g s3_multipart:uploader video
```

creates a video upload controller (video_uploader.rb) which resides in "app/uploaders/multipart" and looks like this:

```ruby
class VideoUploader < ApplicationController
  extend S3Multipart::Uploader::Core

  # Attaches the specified model to the uploader, creating a "has_one" 
  # relationship between the internal upload model and the given model.
  attach :video

  # Only accept certain file types. Expects an array of valid extensions.
  accept %w(wmv avi mp4 mkv mov mpeg)

  # Define the minimum and maximum allowed file sizes (in bytes)
  limit min: 5*1000*1000, max: 2*1000*1000*1000

  # Takes in a block that will be evaluated when the upload has been 
  # successfully initiated. The block will be passed an instance of 
  # the upload object as well as the session hash when the callback is made. 
  # 
  # The following attributes are available on the upload object:
  # - key:       A randomly generated unique key to replace the file
  #              name provided by the client
  # - upload_id: A hash generated by Amazon to identify the multipart upload
  # - name:      The name of the file (including extensions)
  # - location:  The location of the file on S3. Available only to the
  #              upload object passed into the on_complete callback
  #
  on_begin do |upload, session|
    # Code to be evaluated when upload begins  
  end

  # See above comment. Called when the upload has successfully completed
  on_complete do |upload, session|
    # Code to be evaluated when upload completes                                                 
  end

end
```

The generator requires a model to be passed in (in this case, the video model) and automatically creates a "has one" relationship between the upload and the model (the video). For example, in the block that the `on_begin` method takes, a video object could be created (`video = Video.create(name: upload.name)`) and linked with the upload (`upload.video = video`). When the block passed into the `on_complete` is run at a later point in time, the associated video is now accessible by calling `upload.video`. If instead, you want to construct the video object on completion and link the two then, that is ok.

The generator also creates the migration to add this functionality, so make sure to do a `rake db:migrate` after generating the controller. 

To add the multipart uploader to a view, insert the following:

```ruby
<%= multipart_uploader_form(input_name: 'uploader',
                            uploader: 'VideoUploader',
                            button_class: 'submit-button', 
                            button_text: 'Upload selected videos',
                            html: %Q{<button class="upload-button">Select videos</button>}) %>
```

The `multipart_uploader_form` function is a view helper, and generates the necessary input elements. It takes in a string of html to be interpolated between the generated file input element and submit button. It also expects an upload controller (as a string or constant) to be passed in with the 'uploader' option. This links the upload form with the callbacks specified in the given controller.

The code above outputs this:

```html
<input accept="video" data-uploader="7b2a340f42976e5520975b5d5668dc4c19b38f2c" id="uploader" multiple="multiple" name="uploader" type="file">
<button class="upload-button" type="submit">Select videos</button>
<button class="submit-button"><span>Upload selected videos</span></button>
```

Let's return to the javascript that you inserted into the application.js during setup. The S3MP constructor takes in a configuration object with a handful of required callback functions. It also takes in list of files (through the `fileList` property) that is an array of File objects. This could be retrieved by calling `$("#uploader").get(0).files` if the input element had an "uploader" id, or it could be manually constructed. See the internal tests for an example of this manual construction. 

The S3MP constructor also returns an object that you can interact with. Although not demonstrated here, you can call cancel, pause, or resume on this object and pass in the zero-indexed key of the file in the fileList array you want to control.

## Tests

First, create a file `setup_credentials.rb` in the spec folder.

```ruby
# spec/setup_credentials.rb
S3Multipart.configure do |config|
  config.bucket_name   = ''
  config.s3_access_key = ''
  config.s3_secret_key = ''
  config.revision = S3Multipart::Version
end
```

You can now run all of the RSpec and Capybara tests with `rspec spec`

[Combustion](https://github.com/pat/combustion) is also used to simulate a rails application. Paste the following into a `config.ru` file in the base directory:

```ruby
require 'rubygems'
require 'bundler'

Bundler.require :development

Combustion.initialize! :active_record, :action_controller,
                       :action_view, :sprockets

S3Multipart.configure do |config|
  config.bucket_name   = ''
  config.s3_access_key = ''
  config.s3_secret_key = ''
  config.revision = S3Multipart::Version
end

run Combustion::Application
```

and boot up the app by running `rackup`. A fully functional uploader is now available if you visit http://localhost:9292

Jasmine tests are also available for the client-facing javascript library. After installing [Grunt](http://gruntjs.com/) and [PhantomJS](http://phantomjs.org/), and running `npm install` once, you can run the tests headlessly by running `grunt jasmine`. 

To re-build the javascript library, run `grunt concat` and to minify, `grunt min`.

## Contributing

S3_Multipart is very much a work in progress. If you squash a bug, make enhancements, or write more tests, please submit a pull request. 

## Browser Compatibility

The library is working on the latest version of IE, Firefox, Safari, and Chrome. Tests for over 100 browsers are currently being conducted.


## To Do

* ~~If the FileBlob API is not supported on page load, the uploader should just send one giant chunk~~ (DONE)
* Handle network errors in the javascript client library
* ~~File type validations~~ (DONE)
* ~~File size validations~~ (DONE)
* More and better tests
* More browser testing 
* Roll file signing and initiation into one request
