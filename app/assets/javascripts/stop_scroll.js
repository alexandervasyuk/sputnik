function stopScroll(element){
	element.on('mousewheel', function(e, d) {
	    if((this.scrollTop === (element[0].scrollHeight - element.innerHeight()) && d < 0) || (this.scrollTop === 0 && d > 0)) {
	        e.preventDefault();
	    }
	});
}

$(function(){
	stopScroll($('.modal-body'));
});