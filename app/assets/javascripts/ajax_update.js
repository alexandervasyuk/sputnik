/*function ajaxUpdate(postUrl, dataClass, replaceDiv){
    setInterval(function(){
    	var numData = $(dataClass).length;
    	
	     $.ajax({
		    url: postUrl,
		    data: {num: numData},
		    success: function(data) {
			   if (data != "cancel"){
		  	 	$(replaceDiv).html(data);
		 	   }
		     }
	     });
    }, 10000);
}

function postsUpdate(micropostId, postUrl, dataClass, replaceDiv){
	setInterval(function(){
		var numData = $(dataClass).length;
		
		$.ajax({
			url: postUrl,
			data: {num: numData, id: micropostId},
			success: function(data) {
				if (data != "cancel"){
					$(replaceDiv).html(data);
				}
			}
		});
	}, 10000);
}*/