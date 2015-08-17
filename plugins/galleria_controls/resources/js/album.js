Galleria.ready(function() {
    var gallery = this;
    this.addElement('controls').appendChild('container','controls');
    this.$('controls').addClass('btn-group-xs');

    this.addElement('fullscreen').appendChild('controls','fullscreen');
    this.$('fullscreen').addClass('btn').addClass('glyphicon').addClass('glyphicon-fullscreen')
      .click(function(e) {
        gallery.toggleFullscreen();
    });
    this.bind('fullscreen_enter', function(e){
      this.$('fullscreen').addClass('active');
    });
    this.bind('fullscreen_exit', function(e){
      this.$('fullscreen').removeClass('active');
    });
    this.addElement('slideshow').appendChild('controls','slideshow');
    this.$('slideshow').addClass('btn').addClass('glyphicon').addClass('glyphicon-play')
      .click(function(e) {
        gallery.playToggle();
    });
    this.bind('play', function(e){
      this.$('slideshow').addClass('active');
    });
    this.bind('pause', function(e){
      this.$('slideshow').removeClass('active');
    });
    var touch = Galleria.TOUCH;
    if (! touch ) {
    	this.addIdleState(this.get('controls'), { top:-28 });
    }
});
