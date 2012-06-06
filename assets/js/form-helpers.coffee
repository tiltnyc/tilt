loadListFor = (model, type, display) ->
  selector = $("select[name=\"" + model + "[" + type + "]\"]")
  prompt = (if (selector.data("prompt")?) then selector.data("prompt") else "(none)")
  if selector.length
    $.ajax
      type: "GET"
      url: "/" + type + "s.json"
      contentType: "application/json; charset=utf-8"
      dataType: "json"
      success: (msg) ->
        selector.options = []
        $(new Option(prompt, "", true)).appendTo selector
        $.each msg, (index, item) ->
          selected = item._id is selector.data("team")
          $(new Option(item[display], item._id, false, selected)).appendTo selector

      error: ->
        alert "Failed to load " + type + "s"
$ ->
  totalInvested = 0
  investments = []

  appendInvestment = (index, amount) ->
    return if isNaN(amount)
    investments[index] = new Number(amount.toFixed(2))
    total = 0
    (total += val if !isNaN val) for val in investments
    total

  resetValues = ->
    for val, i in investments
      do (val, i) ->
        if !isNaN val
          amount = (val / Math.max(totalInvested, 1))
          $("#percentage-slider-amount-" + i + " span").text Math.round(amount * 100) + "%"
          $("#percentage-slider-amount-" + i + " input").val amount

  $(".percentage-slider").slider
    value: 0
    min: 0
    max: 100
    step: 1
    slide: (event, ui) ->
      value = Math.round(ui.value) / 100
      totalInvested = appendInvestment($(this).data("index"), value)
      resetValues()
      $("#total-invested").text Math.round(Math.min(totalInvested, 1) * 100) + "%"

  loadListFor "user", "team", "name"
  loadListFor "investment", "team", "name"
  loadListFor "investment", "user", "username"
  loadListFor "allocate", "user", "username"    