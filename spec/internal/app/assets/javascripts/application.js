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
//= require jquery.ui.progressbar
//= require s3_multipart/lib

$(function() {
  var file_list, s3mp;

  $(".submit-button").click(function() {
    window.s3mp = new window.S3MP({
      bucket: 'bitcast-bucket',
      fileInputElement: "#uploader",
      fileList: file_list,
      onStart: function(upload) {
        var id = upload.id
          , key = upload.key;

        // Insert the upload details form if only one file upload is going on
        if (file_list.length === 1) {
          // $.ajax({
          //   url: "/videos/"+id+"/settings",
          //   cache: false,
          //   success: function(html){
          //     $(".upload-form").append(html);
          //     $('.edit_video').bind('ajax:success', function(evt, data, status, xhr){
          //       alert("Video updated successfully");
          //     })
          //   }
          // });
        }

        // Hide the upload button + list, and insert the progress bar
        $(".upload-wrapper, .upload-list").hide();
        $(".upload-list").after('<div class="progress-bar-'+key+'"></div>')
        $(".progress-bar-"+key).progressbar({ max: 100 })
          .after('<div class="progress-bar-info progress-bar-info-'+key+'"><span class="name">'+upload.name+'</span><span class="speed"></span></div>');
        
        console.log("File "+key+" has started uploading")
      },
      onComplete: function(upload) {
        $('.progress-bar-'+upload.key).progressbar({ value: 100 });
        $('.progress-bar-info-'+upload.key)
          .find(".speed").html("100% ("+(upload.size/1000000).toFixed(1)+" MB of "+(upload.size/1000000).toFixed(1)+" MB)");

        console.log("File "+upload.key+" successfully uploaded")
      },
      onPause: function(key) {
        console.log("File "+key+" has been paused")
      },
      onResume: function(key) {
        console.log("File "+key+" has been resumed")
      },
      onCancel: function(key) {
        console.log("File upload "+key+" was canceled")
      },
      onError: function() {
        console.log("There was an error")
      },
      onProgress: function(key, size, done, percent, speed) {
        $('.progress-bar-'+key).progressbar({ value: percent });
        $('.progress-bar-info-'+key)
          .find(".speed").html(percent.toFixed(1)+"% ("+(done/1000000).toFixed(1)+" MB of "+(size/1000000).toFixed(1)+" MB) at "+(speed/1000).toFixed(0)+" kbps");
        console.log("File %d is %f percent done (%f of %f total) and uploading at %s", key, percent, done, size, speed);
      }
    });
  });

  // Empty array to store all the files (cannot store in FileList b/c it is read only)
  file_list = [];

  // Code to handle upload buttons + the upload list
  (function() {
    var uploader, cbs;

    // Reference to uploader file element
    uploader = document.getElementById("uploader");

    // Callback functions
    cbs = {

      moveFileInputEl: _.throttle(function(e) {
        var offset = { left: $(uploader).parent().offset().left, top: $(uploader).parent().offset().top };
        uploader.style.left = e.pageX - offset.left - 100 + "px";
        uploader.style.top = e.pageY - offset.top - 5 + "px";
      },50),

      addActiveClass: function() {
        $(".upload-button").addClass("active");
      },

      removeActiveClass: function() {
        $(".upload-button").removeClass("active");
      },

      updateFileList: function() {
        var upload_list, clone, size, num;

        $("#uploader, .upload-button").hide();
        $(".submit-button").show();

        upload_list = $(".upload-list")
        upload_list.show();

        _.each($("#uploader").get(0).files, function(val, key, list) {
          file_list.push(val);

          size = (val.size/1000000).toFixed(1);

          if (upload_list.find("li").length === 2 && upload_list.find("li").data("num") === undefined) {
            clone = upload_list.find("li:first");         
          } else {
            clone = upload_list.find("li:first").clone()          
          }

          clone.find(".name").text(val.name);
          clone.find(".size").text(size + " MB");

          clone.insertBefore(".upload-list ul .select-another-video").attr("data-num", key);
        });

        num = file_list.length
        if (num > 1) {
          $(".upload-list .total").text(num+" files"); 
        }
      },

      removeFile: function(e) {      
        var li = $(this).parent();
        file_list[li.data("num")] = null;
        li.remove();

        // Update "total" span element
        var num = _.without(file_list, null).length;
        if (num > 1) {
          $(".upload-list .total").text(num+" files"); 
        }
        if (num == 1) {
          $(".upload-list .total").text("1 file"); 
        }
      },

      pauseAll: function(e) {
        _.each(file_list, function(file, key) {
          s3mp.pause(key);          
        });
      },

      resumeAll: function(e) {
        _.each(file_list, function(file, key) {
          s3mp.resume(key);          
        });
      }

    }

    $(".upload-wrapper")
      .mouseover(cbs.addActiveClass)
      .mouseleave(cbs.removeActiveClass)
      .mousemove(cbs.moveFileInputEl)
      .live('change',cbs.updateFileList);

    $(".upload-list").on("click", ".delete", cbs.removeFile);

  })();

});

