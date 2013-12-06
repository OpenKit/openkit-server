$(document).ready(function () {

  $("#flash i").click(function(){
    $(this).parent().slideUp();
  })

  // setTimeout(function() {
  //   $('#flash').fadeOut();
  // }, 2500);

  $(".account").click(function(){
    var X=$(this).attr('id');
    if(X==1){
      $(".subnav").hide();
      $(this).attr('id', '0');
      $(this).removeClass('active');
    }
    else{
      $(".subnav").show();
      $(this).attr('id', '1');
      $(this).addClass('active');
    }
  });

  //Mouse click on sub menu
  $(".subnav").mouseup(function(){
    return false
  });

  //Mouse click on my account link
  $(".account").mouseup(function(){
    return false
  });


  //Document Click
  // $(document).mouseup(function(){
  //   $(".subnav").hide();
  //   $(".account").attr('id', '');
  //   $(".account").removeClass('active');
  // });

  // $(".md-trigger").click(function(){
  //   $(".md-modal").addClass("md-show");
  //   return false;
  // });

  // $(".md-close").click(function(){
  //   $(".md-modal").removeClass("md-show");
  //   return false;
  // });
});
