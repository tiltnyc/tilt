(function() {
  var loadListFor;

  loadListFor = function(model, type, display) {
    var prompt, selector;
    selector = $("select[name=\"" + model + "[" + type + "]\"]");
    prompt = ((selector.data("prompt") != null) ? selector.data("prompt") : "(none)");
    if (selector.length) {
      return $.ajax({
        type: "GET",
        url: "/" + type + "s.json",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(msg) {
          var recurse;
          selector.options = [];
          $(new Option(prompt, "", true)).appendTo(selector);
          recurse = function(item, chain) {
            if (!chain.length) return item;
            return recurse(item[chain.shift()], chain);
          };
          return $.each(msg, function(index, item) {
            var label, selected;
            selected = item._id === selector.data("team");
            label = display instanceof Array ? recurse(item, display.concat()) : item[display];
            return $(new Option(label, item._id, false, selected)).appendTo(selector);
          });
        },
        error: function() {
          return alert("Failed to load " + type + "s");
        }
      });
    }
  };

  $(function() {
    var appendInvestment, investments, resetValues, totalInvested;
    totalInvested = 0;
    investments = [];
    appendInvestment = function(index, amount) {
      var total, val, _i, _len;
      if (isNaN(amount)) return;
      investments[index] = new Number(amount.toFixed(2));
      total = 0;
      for (_i = 0, _len = investments.length; _i < _len; _i++) {
        val = investments[_i];
        if (!isNaN(val)) total += val;
      }
      return total;
    };
    resetValues = function() {
      var i, val, _len, _results;
      _results = [];
      for (i = 0, _len = investments.length; i < _len; i++) {
        val = investments[i];
        _results.push((function(val, i) {
          var amount;
          if (!isNaN(val)) {
            amount = val / Math.max(totalInvested, 1);
            $("#percentage-slider-amount-" + i + " span").text(Math.round(amount * 100) + "%");
            return $("#percentage-slider-amount-" + i + " input").val(amount);
          }
        })(val, i));
      }
      return _results;
    };
    $(".percentage-slider").slider({
      value: 0,
      min: 0,
      max: 100,
      step: 1,
      slide: function(event, ui) {
        var value;
        value = Math.round(ui.value) / 100;
        totalInvested = appendInvestment($(this).data("index"), value);
        resetValues();
        return $("#total-invested").text(Math.round(Math.min(totalInvested, 1) * 100) + "%");
      }
    });
    loadListFor("user", "team", "name");
    loadListFor("investment", "team", "name");
    loadListFor("investment", "competitor", ["user", "username"]);
    return loadListFor("allocate", "user", "username");
  });

}).call(this);
