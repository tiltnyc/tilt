$().ready(function(){
  var selector = $('select[name="user[team]"]');
   
  if (selector.length) { 
      
    $.ajax({
      type: "GET",
      url: "/teams.json",
      contentType: "application/json; charset=utf-8",
      dataType: "json",
      success: function(msg) {
        selector.options = []; 
        $.each(msg, function(index, item) {
          $(new Option(item.name, item._id)).appendTo(selector);
        }); 
      },
      error: function() {
          alert("Failed to load genders");
      }
    });

  }
});