exports.error = (req, res, error, redirect) ->
  if req.params.format is "json"
    res.contentType "application/json"
    res.send JSON.stringify(error: error)
  else
    req.flash "error", error
    res.redirect redirect