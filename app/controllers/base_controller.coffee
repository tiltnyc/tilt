class BaseController
  five_hundred: (request, response, error, redirect) ->
    SystemHandlers.error(request, response, error, '/')

module.exports = BaseController
