var Team = require('../models/team');

exports.loadTeamCount = function (req, res, next) {
  Team.count({}, function(err, count){
    if (err) return next(err);
    req.teamCount = count;
    next();  
  })
};