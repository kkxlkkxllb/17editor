var distance, playAudio;

$(function() {
  var $wrap, count, mouthOpen, status;
  $wrap = $('#wrapper');
  status = "sleep";
  mouthOpen = false;
  count = 0;
  return $(document).mousemove(function(e) {
    var diffX, diffY, dist, distM, docH, docW, eye_background, eye_lid, eye_lid_p, eye_translate, mouth_height, mouth_transform;
    docW = $(window).width();
    docH = $(window).height();
    diffX = (docW / 2) - e.clientX;
    diffY = (docH / 2) - 100 - e.clientY;
    dist = distance(docW / 2, docH / 2, e.clientX, e.clientY);
    distM = distance(docW / 2, (docH / 2) + 60, e.clientX, e.clientY);
    if (status === "sleep") {
      if (distM < 200) {
        $wrap.removeClass("sleep").addClass("hungry");
        status = "hungry";
        return playAudio("audio-ohh");
      }
    } else if (status === "hungry") {
      eye_background = Math.floor(diffX / -30) + 'px ' + Math.floor(diffY / -30) + 'px';
      eye_translate = Math.floor(diffX / -50) + 'px, ' + Math.floor(diffY / -100) + 'px';
      $(".eye").css({
        "background-position": eye_background,
        "-webkit-transform": 'translate3d(' + eye_translate + ',0)',
        "-moz-transform": 'translate(' + eye_translate + ')'
      });
      $(".eye:first-child").css({
        "background-position": eye_background,
        "-webkit-transform": 'translate3d(' + eye_translate + ',0) scale(.6)',
        "-moz-transform": 'translate(' + eye_translate + ') scale(.6)'
      });
      eye_lid_p = 100 + Math.floor(diffY / -20);
      eye_lid = '-webkit-gradient(radial, 50% ' + eye_lid_p + '%, 20, 50% ' + eye_lid_p + '%, 50, color-stop(.5, rgba(0,0,0,0)), color-stop(.6, rgba(0,0,0,1)))';
      $(".lid").css({
        "-webkit-mask-image": eye_lid
      });
      if (distM > 200) {
        if (mouthOpen) {
          mouthOpen = false;
          $('#mouth').addClass("out");
          mouth_height = "20px";
          count = 0;
        }
      } else {
        mouth_height = 80 - Math.floor(distM / 3) + 'px';
        if (!mouthOpen) {
          mouthOpen = true;
          $('#mouth').removeClass("out");
        }
      }
      mouth_transform = Math.floor(diffX / -80) + "px, " + Math.floor(diffY / -80) + 'px';
      $("#mouth").css({
        "height": mouth_height,
        "-webkit-transform": 'translate3d(' + mouth_transform + ', 0)',
        "-moz-transform": 'translate(' + mouth_transform + ')'
      });
      if (distM < 30 && count > 50) {
        count = 0;
        $("#mouth").css({
          "height": "",
          "-webkit-transform": "",
          "-moz-transform": ""
        });
        $("body").css({
          "cursor": "none"
        });
        $wrap.removeClass("hungry").addClass("eat");
        playAudio("audio-snap");
        return status = "eat";
      } else {
        return count++;
      }
    } else if (status === "eat") {
      if (distM > 120) {
        $wrap.removeClass("eat").addClass("hungry");
        $("body").css({
          "cursor": ""
        });
        status = "hungry";
        return playAudio("audio-ohh");
      }
    }
  });
});

distance = function(x1, y1, x2, y2) {
  return Math.sqrt(Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2));
};

playAudio = function(id) {
  return $("#" + id)[0].play();
};
