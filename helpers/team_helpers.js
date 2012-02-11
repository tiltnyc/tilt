var Team = require('../models/team');

exports.loadTeamCount = function (req, res, next) {
  Team.count({}, function(err, count){
    if (err) return next(err);
    req.teamCount = count;
    next();  
  })
};

exports.getUserInvestable = function(user, next) {
  var query = {};

  //if logged in user assigned to team
  if (user && !user.is_admin && user.team) query = {_id : {$ne: user.team}};

  Team
    .find(query)
    .asc('name')
    .run(function(err, teams) {
      if (err) return next(err);

      next(null, (teams) ? teams : []);
    });
}