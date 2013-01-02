// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require underscore
//= require_tree .
//= require s3_multipart/s3_multipart

$(function() {
    $(".submit-button").click(function() {
      window.SS3MP = new window.S3MP({
        fileSelector: "#uploader",
        onComplete: function(num) {
          console.log("File "+num+" successfully uploaded")
        },
        onPause: function(num) {
          console.log("File "+num+" has been paused")
        },
        onCancel: function(num) {
          console.log("File upload "+num+" was canceled")
        },
        onError: function() {
          console.log("There was an error")
        },
        onProgress: function(num, size, done, percent, speed) {
          console.log("File %d is %f percent done (%f of %f total) and uploading at %s", num, percent, done, size, speed);
        }
      });
      console.log(SS3MP);
    });


    (function() {
      var uploader, adjust_uploader_position, reset_uploader_position

      uploader = document.getElementById("uploader");

      // Callback functions
      mousemove_fn = _.throttle(function(e) {
        uploader.style.left = e.pageX-280 +"px";
        uploader.style.top = "0px";
      },10);
      mouseover_fn = function() {
        $(".upload-button").addClass("active");
      };
      mouseleave_fn = function() {
        $(".upload-button").removeClass("active");
      }
      change_fn = function() {
        var upload_list, clone, size;

        $(".upload-wrapper").hide();
        $(".submit-button").show();

        upload_list = $(".upload-list")
        upload_list.show();

        _.each($("#uploader").get(0).files, function(val, key, list) {
          size = (val.size/1000000).toFixed(2);

          if (upload_list.find("li").length === 1) {
            clone = upload_list.find("li");         
          } else {
            clone = upload_list.find("li:first").clone()          
          }

          clone.find(".name").text(val.name)
          clone.find(".size").text(size + " mb")

          upload_list.find("ul").append(clone)
        });
      }

      $(".upload-wrapper")
        .mouseover(mouseover_fn)
        .mouseleave(mouseleave_fn)
        .mousemove(mousemove_fn)
        .live('change',change_fn);

    })();

  });