var Team = require('../models/team')
    , RoundHelpers = require('../helpers/round_helpers');

module.exports = function(app){

  // List of Teams  
  app.get('/results.:format?', RoundHelpers.loadCurrentUser, function(req, res){
    Team
      .find({})
      .desc('last_price')
      .run(function(err, teams) {
        if (req.params.format == 'json') {
          res.contentType('application/json');
          res.send(JSON.stringify(teams));
        }
        else {
          res.render('teams/index', {
            title: 'Team Results',
            teams: teams
          });
        }
      });
  }); 
};