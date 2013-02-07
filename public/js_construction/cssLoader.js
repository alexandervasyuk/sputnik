$(function() {

		jQuery('.open-header').click(showHeader);
		jQuery('.close-header').click(hideHeader);
		
		function showHeader(){
		jQuery('.header-content').slideDown('medium');
		jQuery('.close-header').slideDown('fast');
		jQuery('.open-header').fadeOut('fast');}
		
		function hideHeader(){
		jQuery('.header-content').slideUp('medium');
		jQuery('.close-header').fadeOut('fast');
		jQuery('.open-header').fadeIn('fast');}
		
		jQuery('#switcher_btn').click(showPanel);
		jQuery('.close_btn').click(hidePanel);
		
		function showPanel(){
		jQuery('#styleSwitcher').delay(100).slideDown('medium');
		jQuery('#switcher_btn').fadeOut('fast');}
		
		function hidePanel(){
		jQuery('#styleSwitcher').fadeOut('medium');
		jQuery('#switcher_btn').delay(100).fadeIn('slow');}
		
		
});

		

