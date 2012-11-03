$(function(){
	$('#profile_image').click(displayOverlay);
	
	$('#overlay').click(closeOverlay);
});

function displayOverlay(){
	$('#overlay').show();
	$('#crop_div').show()
}

function closeOverlay(){
	$('#overlay').hide();
	$('#crop_div').hide();
	
	$('#crop_div').css("width", "340px");
	$('#crop_div').css("height", "170px");
	$('#crop_div').css("margin-top", "-160px");
	$('#crop_div').css("margin-left", "-170px");
	
	$('#image_area').hide();
	$('#file_selection').show();
}

function switchToCropDisplay(){
	$('#file_selection').hide();
	
	$('#crop_div').css("width", "550px");
	$('#crop_div').css("height", "460px");
	$('#crop_div').css("margin-top", "-230px");
	$('#crop_div').css("margin-left", "-275px");
	
  	$('#crop_image').Jcrop({
    	onChange: update_crop,
    	onSelect: update_crop,
    	aspectRatio: 1,
    	boxWidth: 550,
    	boxHeight: 550
  	});
  	
  	$('#image_area').show();
}

function update_crop(coords){
	$('#x').val(coords.x);
	$('#y').val(coords.y);
	$('#w').val(coords.w);
	$('#h').val(coords.h);
}
