BaseController = require './base_controller'

class HomeController extends BaseController
  index: (request, response) ->
    response.render 'index',
      title: 'tilt'

  login: (request, response) ->
    response.contentType('application/json')
    if (request.user)
      response.send(JSON.stringify(request.user))
    else
      response.send(JSON.stringify({error: "not authorized."}))

module.exports = HomeController