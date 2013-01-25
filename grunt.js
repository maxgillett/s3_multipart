module.exports = function(grunt) {

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-jasmine-runner');

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    concat: {
      lib : {
        src : [
          'javascripts/header.js',
          'javascripts/s3mp.js',
          'javascripts/upload.js',
          'javascripts/uploadpart.js',
          'javascripts/footer.js'
        ],
        dest : 'vendor/assets/javascripts/s3_multipart/lib.js'
      }
    },

    jasmine : {
      src : [
        'javascripts/libs/underscore.js',
        'javascripts/s3mp.js',
        'javascripts/upload.js',
        'javascripts/uploadpart.js'
      ],
      helpers : 'spec/javascripts/helpers/*.js',
      specs : 'spec/javascripts/*.js'
    },

    min: {
      myPlugin: {
        src: [
          '<config:concat.lib.dest>'
        ],
        dest: 'vendor/assets/javascripts/s3_multipart/lib.min.js'
      }
    }    

  });
};