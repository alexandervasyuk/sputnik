function ajaxUpdate(postUrl, dataClass, replaceDiv){
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
}

function notificationsUpdate(){
	setInterval(function(){
		var notification = $('#notification');
		
		$.ajax({
			url: "/notifications/refresh",
			data: {latest: $(notification).attr("data-latest")},
			success: function(data) {
				if (data != "cancel"){
					var content = $('#notification').attr("data-content");
					
					var update = content.substring(0, 26) + data[0] + content.substring(26);
					
					var numberUpdates = data[0].match(/<li/g).length;
					
					$('#notification').attr("data-content", update);
					
					var newNotifications = parseInt($('.notification-badge')[0].innerHTML);
					newNotifications += numberUpdates;
					
					$('.notification-badge')[0].innerHTML = "" + newNotifications;
					
					$('#notification').attr("data-latest", data[1]);
				}
			}
		});
	}, 10000);
}