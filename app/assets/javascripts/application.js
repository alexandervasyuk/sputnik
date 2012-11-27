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
//= require jquery
//= require bootstrap
//= require jquery_ujs
//= require jquery.remotipart
//= require detect_timezone
//= require jquery.detect_timezone
//= require stop_scroll
//= require crop
//= require detail
//= require ajax_update
//= require mousewheel
//= require confirm_delete
//= require bootstrap_custom

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
	

}); 


