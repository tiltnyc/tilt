var Round = require('../models/round');

exports.loadCurrentRound = function (req, res, next) {
  Round
    .findOne({is_current: true})
    .run(function(err, round) {
      if (err) return next(err);
      req.currentRound = round;
      next();
    });  
};

exports.loadFirstRound = function(req, res, next) {
   Round.findOne({number: 1}).run(function(err, round){
      if (err) return next(err);
      req.firstRound = round;
      next();
   });
}
