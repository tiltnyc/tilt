class BaseController
  updateIfChanged: (props, to, from) ->
    to[key] = from[key] for key in props when from[key] 

  error: (request, response, msg, redirect) ->
    if request.params.format is 'json'
      response.contentType 'application/json'
      response.send JSON.stringify(error: msg)
    else
      request.flash 'error', msg
      response.redirect redirect

module.exports = BaseController
