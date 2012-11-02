$(function(){
	$('#profile_image').overlay();
	$('#profile_image').click(displayOverlay);
	
	$('#overlay').click(closeOverlay);
});

function displayOverlay(){
	$('#overlay').show();
}

function closeOverlay(){
	$('#overlay').hide();
	$('#profile_image').overlay().close();
}

function resetOverlay(){
	$('#profile_image').overlay().close();
	$('#profile_image').overlay().load();
}

function switchToCropDisplay(){
	$('#file_selection').hide();
	
  	$('#crop_image').Jcrop({
    	onChange: update_crop,
    	onSelect: update_crop,
    	aspectRatio: 1
  	});
  	
  	$('#image_area').show();
}

function update_crop(coords){
	$('#x').val(coords.x);
	$('#y').val(coords.y);
	$('#w').val(coords.w);
	$('#h').val(coords.h);
}
