// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code direcly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery-sub
//= require bootstrap
//= require jquery_ujs
//= require jquery.remotipart
//= require detect_timezone
//= require jquery.detect_timezone
//= require ajax_update
//= require stop_scroll
//= require crop
//= require detail
//= require mousewheel
//= require confirm_delete
//= require bootstrap_custom
//= require jquery-ui.min

$(function () { 

	$("#notification").popover({html:true, placement: 'bottom'}).click(function(){
		var menu = $('.popover-content');

		stopScroll(menu)

		notifications_ids = []
		$.each($('.notification_item'), function(key,value) { notifications_ids.push(value.id) })
		$.ajax({
		    url: '/notifications/update_read',
		    data: { ids: notifications_ids },
		    success: function(data) {
		    }
	    });
		    
		$('#notification').attr('data-content', $('#notification').attr('data-content').replace('unread', ''));
		$('.notification-badge').replaceWith('<span class="notification-badge badge badge-inverse">0</span>');

	});
	$('#notification').tooltip();
	$('#settings').tooltip();
	$('#signout').tooltip();
	$('#my-profile').tooltip();
	$('#feed').tooltip();
	
	$('#location_input').on( "autocompleteresponse", function( event, ui ) {
		if ($('#location_input').val().length > 3 && ui.content.length == 0){
			$('#location-error').html("<p>searching</p>");
			$.ajax({
				url: '/google/places/autocomplete',
				type: 'POST',
				data: {name: $('#location_input').val()},
				success: function(response) {
					if (response.status == "OK"){
						var autocompletes = [];

						for (var i = 0; i < response.results.length; i++) {
							autocompletes.push(response.results[i].name);
						}
						
						$('#location_input').autocomplete("option", "source", autocompletes);
					
						$('#location_input').autocomplete("search", $('#location_input').val());
					}
					else{
						$('#location-error').html("<p>No results found</p><a href=\"#map-modal\" role=\"button\" class=\"btn\" data-toggle=\"modal\">I'll find it myself</a>")
					}
				}
			});
		}
	});
}); 


