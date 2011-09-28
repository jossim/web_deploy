$(document).ready(function() {
    //var int=self.setInterval("get_time()",2000);
    $('#presentation').fathom(); 
});
function get_time(){
    //alert("hey");
    $.ajax({
	type: "GET",
	url: "/test",
	dataType: "json",
	success: function(msg){
	    $('.cover').removeClass().addClass('cover '+msg.color);
	    $('.cover').append("hey");
	    //alert(msg.color);
	}
    });
}