(function(global) {
  global.S3MP = (function() {

    // Wrap this into underscore library extension
    _.mixin({
      findIndex : function (collection, filter) {
        for (var i = 0; i < collection.length; i++) {
          if (filter(collection[i], i, collection)) {
            return i;
          }
        }
        return -1;
      }
    });