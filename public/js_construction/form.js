$(document).ready(function() {
	
	//if submit button is clicked
	$('#submit').click(function () {		
		
		//Get the data from all the fields
		var email = $('input[name=email]');
		
		//Simple validation to make sure user entered something
		//If error found, add hightlight class to the text field
		if (email.val()=='') {
			email.addClass('');
			return false;
		} else email.removeClass('');
		
		//organize the data properly
		var data = '&email=' + email.val();				
		
		//disabled all the text fields
		$('.text').attr('disabled','true');
		
		//show the loading sign
		$('.loading').show();
		
		//start the ajax
		$.ajax({
			//this is the php file that processes the data and send mail
			url: "process.php",	
			
			//GET method is used
			type: "GET",

			//pass the data			
			data: data,		
			
			//Do not cache the page
			cache: false,
			
			//success
			success: function (html) {				
				//if process.php returned 1/true (send mail success)
				if (html==1) {					

					//hide the form
					$('.form').fadeOut('slow');

					//show the success message
					$('.done').fadeIn('slow');
					
				//if process.php returned 0/false (send mail failed)
				} else alert('Sorry, unexpected error. Please try again later.');				
			}		
		});
	
		//cancel the submit button default behaviours
		return false;
	});	
});	
