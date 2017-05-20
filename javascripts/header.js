(function(global) {
  global.S3MP = (function() {

    // Wrap this into underscore library extension
    _.mixin({
      s3mp_findIndex : function (collection, filter) {
        for (var i = 0; i < collection.length; i++) {
          if (filter(collection[i], i, collection)) {
            return i;
          }
        }
        return -1;
      }
    });