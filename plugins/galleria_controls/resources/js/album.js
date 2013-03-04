Galleria.ready(function() {
    var gallery = this;
    this.addElement('controls').appendChild('container','controls');
    this.addElement('fullscreen').appendChild('controls','fullscreen');
    this.$('fullscreen').text('fullscreen').click(function(e) {
      gallery.toggleFullscreen();
    });
    this.bind('fullscreen_enter', function(e){
      this.$('fullscreen').addClass('active')
    });
    this.bind('fullscreen_exit', function(e){
      this.$('fullscreen').removeClass('active')
    });
    this.addElement('slideshow').appendChild('controls','slideshow');
    this.$('slideshow').text('slideshow').click(function(e) {
      gallery.playToggle();
    });
    this.bind('play', function(e){
      this.$('slideshow').addClass('active')
    });
    this.bind('pause', function(e){
      this.$('slideshow').removeClass('active')
    });
});
