/* Helper Functions */
			
function resetLocationAutocomplete(markers) {
	clearMap(markers);
	clearLocationAutocomplete();
}

/* End Helper Functions */

function createAutocompletePopover(element) {
	var markers = [];
	var map = null;
	var customLocation = null;
	var geocoder;
	
	setLocationAutocompletePopover(element);
	
	$(element).keyup(function(e) {
		if ($(this).val().length > 3) {
			//Checks if the popover is visible on the field
			if (!isPopoverVisible(this)){
				$(this).popover('show');
				
				curLocation = getCurrentGoogleLatLng();
				var mapOptions;
				
				// Initialize Google Geocoder
				geocoder = new google.maps.Geocoder();
				
				// Setting the correct options depending on 
				if (curLocation != null) {
					// Setting initial map options
					mapOptions = {
					  center: curLocation,
					  zoom: 10,
					  mapTypeId: google.maps.MapTypeId.ROADMAP
					};

					reverseGeocodeCity(curLocation, geocoder, updatePopoverAfterReverseGeocode);
				}
				else {
					mapOptions = {
						center: getUSGeographicalCenter(),
						zoom: 3,
						mapTypeId: google.maps.MapTypeId.ROADMAP
					};
					
					setCurrentCity("Unknown");
				}
				
				// Attach the functionality that will allow the user to change their current location in the session
				$('#location_reset_btn').click(function(){
					geocodeCity(map, markers, $('#location_reset_field').val(), geocoder, updatePopoverAfterGeocode);
				});
				
				// Create a new map
				var mapView = $(element).next('.popover').find('.map_view');
				map = new google.maps.Map(mapView[0], mapOptions);
				
				// Custom location selection
				google.maps.event.addListener(map, 'click', function(event) {
				  customLocation = placeCustomLocation(event.latLng, customLocation, map);
				});
			}
			
			resetLocationAutocomplete(markers);
			setSearchMessage("Searching");
			
			$.ajax({
				url: '/google/places/autocomplete',
				type: 'POST',
				data: {name: $(element).val()},
				success: function(response) {
					resetLocationAutocomplete(markers);
				
					if (response.length > 0) {							
						var average_latitude = 0.0;
						var average_longitude = 0.0;
					
						for (var i = 0; i < response.length; i++) {								
							average_latitude += parseFloat(response[i].latitude);
							average_longitude += parseFloat(response[i].longitude);
							
							placeMarker(map, new google.maps.LatLng(parseFloat(response[i].latitude), parseFloat(response[i].longitude)), markers, i);
							
							addToAutocompleteList(response[i].name, response[i].address, geocoder, (i+1), parseFloat(response[i].latitude), parseFloat(response[i].longitude), element);
						}
						
						map.setCenter(new google.maps.LatLng(average_latitude/response.length, average_longitude/response.length));
						
						$('#location_autocomplete_options').html("or click on the map to mark it");
					}
					else {
						setSearchMessage("No Results Found");
						$('#location_autocomplete_options').html("Click on the map to mark it");
					}
				}
			});
		}
	});
}