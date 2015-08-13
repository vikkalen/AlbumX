var galleria_portrait = $(window).height() > $(window).width();

$(function(){
  var height = galleria_portrait ? 16/9 : 9/16;
  $('#galleria').galleria({height:height});
});

Galleria.ready(function() {
    var gallery = this;
    window.onresize = function(){
      var portrait = $(window).height() > $(window).width();
      if(portrait != galleria_portrait){
        galleria_portrait = portrait;
        var height = portrait ? 16/9 : 9/16;
        gallery._userRatio = height;
        if(!gallery._fullscreen.active) gallery.resize();
      }
    };
});
