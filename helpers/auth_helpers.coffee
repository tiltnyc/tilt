User = require("../models/user")
exports.restricted = (req, res, next) ->
  if not req.user or not req.user.is_admin
    err = new Error("Unauthorized.")
    req.flash "error", err
    next err
  else
    next()

exports.loggedIn = (req, res, next) ->
  unless req.user
    err = new Error("Not logged in.")
    req.flash "error", err
    next err
  else
    next()