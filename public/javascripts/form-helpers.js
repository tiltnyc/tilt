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
        $(new Option("(none)","",true)).appendTo(selector);
        $.each(msg, function(index, item) {
          var selected = item._id == selector.data('team');
          $(new Option(item.name, item._id, false, selected)).appendTo(selector);
        }); 
      },
      error: function() {
          alert("Failed to load genders");
      }
    });

  }
});