var Team = require('../models/team')
    , RoundHelpers = require('../helpers/round_helpers');

module.exports = function(app){

  // List of Teams  
  app.get('/results.:format?', RoundHelpers.loadCurrentRound, function(req, res){
    Team
      .find({})
      .desc('last_price')
      .run(function(err, teams) {
        if (req.params.format == 'json') {
          res.contentType('application/json');
          res.send(JSON.stringify(teams));
        }
        else {
          var roundForResults = (req.currentRound.processed) ? req.currentRound.number : Math.max(req.currentRound.number - 1, 1);

          res.render('results/index', {
            title: 'Round ' + roundForResults + ' results',
            teams: teams,
            roundForResults: roundForResults,
            currentRound: req.currentRound
          });
        }
      });
  }); 
};