var User = require('../models/user');

exports.restricted = function(req, res, next) {
  if (!req.user || !req.user.is_admin) { 
    var err = new Error("Unauthorized.");
    req.flash('error', err);
    next(err);
  }
  else next();
};

exports.loggedIn = function(req, res, next) {
  if (!req.user) {
    var err = new Error("Not logged in.");
    req.flash('error', err);
    next(err);
  }
  else next();
};