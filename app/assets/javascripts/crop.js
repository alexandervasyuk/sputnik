var jcrop_api = null;

$(document).ready(function(){
	$('#profile_image').click(displayOverlay);
	$('#change_profile_image').click(displayOverlay);
	$('#overlay').click(closeOverlay);
	
	$('.test-tooltip').tooltip();
	
	$('.btn-loading').unbind('click');
	$('.btn-loading').click(setLoadingText);
});

function setLoadingText(){
	$(this).attr('value', $(this).attr('data-loading-text'));
	$(this).attr('disabled', 'disabled');
	$(this).closest('form').submit();
}


function clearFileInput(){ 
    var oldInput = document.getElementById("fileinput"); 
     
    var newInput = document.createElement("input"); 
     
    newInput.type = "file"; 
    newInput.id = oldInput.id; 
    newInput.name = oldInput.name; 
    newInput.className = oldInput.className; 
    newInput.style.cssText = oldInput.style.cssText; 
    // copy any other relevant attributes 
     
    oldInput.parentNode.replaceChild(newInput, oldInput); 
}

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
	
	$('#image_crop_upload').attr('value', 'Upload');
	$('#image_crop_upload').removeAttr('disabled');
	$('#crop_btn').attr('value', 'Crop');
	$('#crop_btn').removeAttr('disabled');
	
	//clearFileInput();
}

function switchToCropDisplay(){
	$('#file_selection').hide();
	
	$('#crop_div').css("width", "550px");
	$('#crop_div').css("height", "460px");
	$('#crop_div').css("margin-top", "-230px");
	$('#crop_div').css("margin-left", "-275px");
	
	if (jcrop_api != null){
		jcrop_api.setImage($('#crop_image').attr('src'));
	}
	else{
	  	jcrop_api = $.Jcrop('#crop_image', {
	    	onChange: update_crop,
	    	onSelect: update_crop,
	    	aspectRatio: 1,
	    	boxWidth: 550,
	    	boxHeight: 550
	  	});
  	}
  	
  	$('#image_area').show();
}

function update_crop(coords){
	$('#x').val(coords.x);
	$('#y').val(coords.y);
	$('#w').val(coords.w);
	$('#h').val(coords.h);
}