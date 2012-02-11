var User = require('../models/user')
  , Investment = require('../models/investment');

exports.loadInvestments = function(user, next) {
  Investment
    .find({user: user._id})
    .populate('team')
    .asc('round', 'team.name')
    .run(function(err, investments) {
      if (err) return next(err);
      next(null, investments);
    });
};