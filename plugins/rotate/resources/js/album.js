Galleria.ready(function() {
    var gallery = this;
    this.addElement('rotate').appendChild('controls','rotate');
    this.$('rotate').addClass('glyphicon').addClass('glyphicon-repeat')
      .click(function(e) {
        var img = $(gallery.getActiveImage());
        gallery.rotate(img, gallery.getData(), 90);
    });
    this.bind('loadfinish', function(e){
      gallery.rotate($(e.imageTarget), e.galleriaData, 0);
    });
    this.bind('rescale', function(e){
      gallery.rotate($(gallery.getActiveImage()), gallery.getData(), 0);
    });
    this.rotate = function(img, data, rotate){
      var oldRotate = data.rotate;
      if(!oldRotate) oldRotate = 0;
      var rotate = (oldRotate + rotate) % 360;
      var scale = 1;
      if (rotate % 180 == 90) scale = img.height()/img.width();
      if (gallery._userRatio > 1) scale = 1/scale;
      var transform = 'rotate('+rotate+'deg) scale('+scale+','+scale+')'
      data.rotate = rotate;
      img.css('-moz-transform', transform);
      img.css('-webkit-transform', transform);
      img.css('-o-transform', transform);
      img.css('-ms-transform', transform);
      img.css('transform', transform);
    };
});
