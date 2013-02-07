$(document).ready(function(){

	$('#cbox').jflickrfeed({
		limit: 10,
		qstrings: {
			id: 'yourid'
		},
		itemTemplate: '<li>'+
						'<a rel="colorbox" href="{{image}}" title="{{title}}" target="_blank">' +
							'<img src="{{image_s}}" alt="{{title}}" />' +
						'</a>' +
					  '</li>'
	}, function(data) {
		$('#cbox a').colorbox();
	});
	
});