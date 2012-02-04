$().ready(function(){
  loadListFor('user', 'team', 'name');
  loadListFor('investment', 'team', 'name');
  loadListFor('investment', 'user', 'username');
  loadListFor('allocate', 'user', 'username'); 


  $('.percentage-slider').slider({
    value: 0
    , min: 0
    , max: 100
    , step: 1 
    , slide: function(event, ui) {
        var value = Math.round(ui.value) / 100;
        $(this).siblings('.percentage-slider-amount').find('span').text(ui.value + "%");
        $(this).siblings('.percentage-slider-amount').find('input').val(value);
        totalInvested = appendInvestment($(this).data('index'), value); 
        $('#total-invested').text(Math.round(totalInvested * 100) + '%');
      }  
  });

  var totalInvested = 0;
  var investments = [];

  function appendInvestment(index, amount) {
    if (isNaN(amount)) return;
    investments[index] = new Number(amount.toFixed(2));
    var total = 0;
    investments.forEach(function(val) { 
      total += val;
    }); 
    return total;
  }
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
