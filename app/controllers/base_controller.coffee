class BaseController
  updateIfChanged: (props, to, from) ->
    to[key] = from[key] for key in props when from[key] 

module.exports = BaseController
