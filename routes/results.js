var Result = require('../models/result')
  , Team = require('../models/team')
  , RoundHelpers = require('../helpers/round_helpers');

module.exports = function(app){

  // List of Teams  
  app.get('/results.:format?', RoundHelpers.loadCurrentRound, function(req, res){

    Result
      .find({})
      .populate('team').populate('round')
      .desc('after_price')
      .run(function(err, results){

        //do group by round
        var roundResults = [];
        results.forEach(function(result){
          var singleRoundResults = [];
          if (!roundResults[result.round.number - 1]) roundResults[result.round.number - 1] = singleRoundResults;
          else singleRoundResults = roundResults[result.round.number - 1];

          singleRoundResults.push(result);
        });

        if (req.params.format == 'json') {
          res.contentType('application/json');
          res.send(JSON.stringify(roundResults));
        }
        else {
          var lastResultRound = 1; 
          if (req.currentRound) lastResultRound = (req.currentRound.processed) ? req.currentRound.number : Math.max(req.currentRound.number - 1, 1);

          res.render('results/index', {
            title: 'Current Results',
            results: roundResults,
            lastResultRound: lastResultRound,
            currentRound: req.currentRound
          });
        }
         
      });
  }); 
};