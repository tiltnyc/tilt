var Team = require('../models/team');

exports.loadTeamCount = function (req, res, next) {
  Team.count({}, function(err, count){
    req.teamCount = count;
    next();  
  })
};