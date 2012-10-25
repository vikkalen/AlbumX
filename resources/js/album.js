$(function(){
  $('#galleria').galleria({height:9/16});

Galleria.ready(function() {
    var gallery = this;
    this.addElement('controls').appendChild('container','controls');
    this.addElement('fullscreen').appendChild('controls','fullscreen');
    this.$('fullscreen').text('fullscreen').click(function(e) {
      gallery.toggleFullscreen();
    });
    this.addElement('slideshow').appendChild('controls','slideshow');
    this.$('slideshow').text('slideshow').click(function(e) {
      gallery.playToggle();
    });
});

});

