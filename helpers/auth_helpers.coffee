User = require("../models/user")
exports.restricted = (req, res, next) ->
  if not req.user or not req.user.is_admin
    req.flash "error", new Error("Unauthorized.")
    res.redirect "/"
  else
    next()

exports.loggedIn = (req, res, next) ->
  unless req.user
    req.flash "error", new Error("Not logged in.")
    res.redirect "/"
  else
    next()