$(".destroy").bind "click", (e) ->
  e.preventDefault()
  if confirm("Are you sure you want to delete this item?")
    element = $(this)
    form = $("<form></form>")
    form.attr(
      method: "POST"
      action: element.attr("href")
    ).hide().append("<input type=\"hidden\" />").find("input").attr(
      name: "_method"
      value: "delete"
    ).end().submit()

$(".confirm").bind "click", (e) ->
  e.preventDefault()
  if confirm($(this).data("message"))
    element = $(this)
    form = $("<form></form>")
    form.attr(
      method: "POST"
      action: element.attr("href")
    ).hide().submit()