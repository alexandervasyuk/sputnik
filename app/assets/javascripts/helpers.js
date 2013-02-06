/* Globals */

/* Location Autocomplete Popovers */

// Adds the correct html data to the element that will have a popover on it
function setLocationAutocompletePopover(element) {
	$(element).attr('data-content', "<div class=\"map_view\"></div><div class=\"list_view\"><ol id=\"location_name_list\"></ol><div id=\"location_autocomplete_options\"></div><div id=\"current_location\"><p>Your current location is <span id=\"current_city\"></span></p><div><input id=\"location_reset_field\" class=\"input\" type=\"text\"></input><input id=\"location_reset_btn\" class=\"btn\" type=\"button\" value=\"correct\"></input></div></div></div>");

	$(element).popover({
		trigger: 'manual',
		html: true})
	.click(function(event){
		event.preventDefault();
	});
}

// Checks whether an element has a popover visible on it
function isPopoverVisible(element) {
	return $(element).next('div.popover:visible').length;
}

function updatePopoverAfterReverseGeocode(address) {
	$('#current_city').html(address);
}

function updatePopoverAfterGeocode(map, markers, latitude, longitude, address) {
	$('#current_city').html(address);
	
	map.setCenter(new google.maps.LatLng(latitude, longitude));
	
	setCookieLatitude(latitude);
	setCookieLongitude(longitude);
	
	clearMap(markers);
	clearLocationAutocomplete();
}

function setCurrentCity(cityName) {
	$('#current_city').html(cityName);
}

function setSearchMessage(message) {
	$('#location_autocomplete_message').html(message);
}

function addToAutocompleteList(info, address, geocoder, index, latitude, longitude, field) {
	$('#location_name_list').append("<li><span class=\"place_name\">" + info + "</span><span class=\"place_address\">" + address + "</span>" + "</li>");
	
	$('#location_name_list').children().last().click(function() {
		$(field).val($(this).children().first().html());
	});
}

// Clears all of the elements that are responsible for displaying information about the location autocomplete search
function clearLocationAutocomplete() {
	$('#location_name_list').empty();
	$('#location_autocomplete_message').empty();
	$('#location_autocomplete_options').empty();
}

/* Time Helper Popovers */
function setTimeHelperPopover(element) {
	$(element).attr("data-content", "<div class=\"time_helper\"><div id=\"date_picker\"></div></div>");
	
	$(element).popover({
		trigger: 'manual',
		html: true})
	.click(function(event){
		event.preventDefault();
	});
}


/* Google Maps */

// Retrieves the user's current position as a Google LatLng object from the session
function getCurrentGoogleLatLng() {
	var latitude = getCookieLatitude();
	var longitude = getCookieLongitude();

	if (latitude != null && longitude != null) {
		var latFloat = parseFloat(latitude);
		var longFloat = parseFloat(longitude);
		
		if (latFloat != NaN && longFloat != NaN) {
			return new google.maps.LatLng(latFloat, longFloat);
		}
	}
	
	return null;
}

// Gives the google LatLng object with the center of the United States Loaded
function getUSGeographicalCenter() {
	return new google.maps.LatLng(38.0, -97.0);
}

// Reverse geocodes for the city and stores the result in an HTML element
function reverseGeocodeCity(location, geocoder, callback) {
	geocoder.geocode({'latLng': location}, function(results, status) {
		if (status == google.maps.GeocoderStatus.OK) {
			for (var i = 0; i < results.length; i++) {
				if (isLocality(results[i])) {
					callback(results[i].formatted_address);
					break;
				}
			}
		}
	});
}

function reverseGeocodeAddressForListItem(location, info, geocoder, index) {
	geocoder.geocode({'latLng': location}, function(results, status) {
		if (status == google.maps.GeocoderStatus.OK) {
			var address = results[0].formatted_address;
			
			var address1 = address.substring(0, address.indexOf(','));
			var address2 = address.substring(address.indexOf(',') + 2);
			
			$('#li'+ index).html('<span class="location_name">' + info + '</span>' + '<span class="location_address1">' + address1 + '</span>' + '<span class="location_address2">' + address2 + '</span>');
		}
		else {
			setTimeout(function() {
				reverseGeocodeAddressForListItem(location, info, geocoder, index);
			}, 200);
		}
	});
}

// Gives the latitude and longitude given the address
function geocodeCity(map, markers, address, geocoder, callback) {
	geocoder.geocode({'address': address}, function(results, status) {
		if (status == google.maps.GeocoderStatus.OK) {
			for (var i = 0; i < results.length; i++) {
				if (isLocality(results[i])) {
					var latitude = round(getLatitudeFromResult(results[0]), 3);
					var longitude = round(getLongitudeFromResult(results[0]), 3);
					
					setCookieLatitude(latitude);
					setCookieLongitude(longitude);
					
					callback(map, markers, latitude, longitude, results[0].formatted_address);			
				}
			}
		}	
	});
}

// Checks if a result returned by the geocoder is in fact a locality (town/city)
function isLocality(result) {
	if (result && result.types && result.types instanceof Array) {
		return result.types.indexOf("locality") > -1;
	}
	else {
		console.log("Attempting to determine if google geocode result is locality with incorrect input");
		console.log("result: " + result);
		
		if (result.types) {
			console.log("result types: " + result.types);
		}
	}
}

// Places a marker down 
function placeMarker(map, location, markers, i){
	setTimeout(function() {
		var marker = new google.maps.Marker({
			position: location,
			animation: google.maps.Animation.DROP,
			map: map,
			icon: 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=' + (i + 1) + '|FF0000|000000'
		});
		
		markers.push(marker);
	}, i * 200);
}

// Places a custom marker down
function placeCustomLocation(location, customLocation, map) {
	if (customLocation) {
		customLocation.setPosition(location);
	}
	else {
		customLocation = new google.maps.Marker({
			position: location,
			map: map,
			draggable: true,
			icon: 'bluedot.png'
		});
	}
	
	return customLocation;
}

// Removes all  of the markers on a map
function clearMap(markers) {
	for (var j = 0; j < markers.length; j++) {
		markers[j].setMap(null);
	}
	
	markers.length = 0;
}


// Gets the latitude from the result of a reverse geocoding
function getLatitudeFromResult(result) {
	if (result && result.geometry && result.geometry.location) {
		return result.geometry.location.lat();
	}
	else {
		console.log("Attempting to get latitude from google geocode result with incorrect input");
		console.log("result: " + result);
		
		if (result) {
			console.log("geometry: " + result.geometry);
			
			if (result.geometry) {
				console.log("location: " + result.geometry.location);
			}
		}
	}
}

// Gets the longitude from the result of a reverse geocoding
function getLongitudeFromResult(result) {
	if (result && result.geometry && result.geometry.location) {
		return result.geometry.location.lng();
	}
	else {
		console.log("Attempting to get longitude from google geocode result with incorrect input");
		console.log("result: " + result);
		
		if (result) {
			console.log("geometry: " + result.geometry);
			
			if (result.geometry) {
				console.log("location: " + result.geometry.location);
			}
		}
	}
}

/* Cookies */

function getCookieLatitude() {
	return $.cookie("latitude");
}

function getCookieLongitude() {
	return $.cookie("longitude");
}

function setCookieLatitude(latitude) {
	if (latitude && typeof latitude == "number") {
		$.cookie("latitude", latitude, { path: '/' });
	}
	else {
		console.log("Attempting to set latitude to non number");
		console.log("Latitude: " + latitude);
	}
}

function setCookieLongitude(longitude) {
	if (longitude && typeof longitude == "number") {
		$.cookie("longitude", longitude, { path: '/' });
	}
	else {
		console.log("Attempting to set longitude to non number");
		console.log("Longitude: " + longitude);
	}
}

/* MISC */
function round(number, precision) {
	if (number && precision && typeof number == "number" && typeof precision == "number") {
		var rounding = Math.pow(10, precision);
		
		return Math.round(number * rounding) / rounding;
	}
	else {
		console.log("Attempting to round using non numbers");
		console.log("Number: " + number);
		console.log("Precision: " + precision);
	}
}