$().ready(function(){
  loadListFor('user', 'team', 'name');
  loadListFor('investment', 'team', 'name');
  loadListFor('investment', 'user', 'username');
  loadListFor('allocate', 'user', 'username'); 
});

function loadListFor(model, type, display) {
  var selector = $('select[name="' + model + '[' + type + ']"]');
  var prompt = (selector.data('prompt') != null) ? selector.data('prompt') : '(none)';
   
  if (selector.length) { 
      
    $.ajax({
      type: "GET",
      url: "/" + type + "s.json",
      contentType: "application/json; charset=utf-8",
      dataType: "json",
      success: function(msg) {
        selector.options = [];
        $(new Option(prompt,"",true)).appendTo(selector);
        $.each(msg, function(index, item) {
          var selected = item._id == selector.data('team');
          $(new Option(item[display], item._id, false, selected)).appendTo(selector);
        }); 
      },
      error: function() {
          alert("Failed to load " + type + "s");
      }
    });
  }
}