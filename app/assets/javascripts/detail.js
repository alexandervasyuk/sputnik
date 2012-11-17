$(function(){
	initialize();
});

function initialize(){	
	$(".feed_item").click(function(event){
		if(event.target != this){ return true; }
		window.location = "/microposts/" + $(this).attr('id') + "/detail";
	});
	
	//$('#image_crop_upload').submit(setUploadButtonToLoading);
	//$('#crop_btn').click(setCropButtonToLoading);
}