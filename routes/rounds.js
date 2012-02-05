var Round = require('../models/round');

module.exports = function(app){

  // Rounds control
  app.get('/rounds', function(req, res){
    Round
      .find({})
      .asc('number') 
      .run(function(err, rounds) {
       
        res.render('rounds/index', {
          title: 'Rounds',
          rounds: rounds
        });   
      });   
  });

  //Append new round
  app.post('/rounds', function(req, res) {
    Round.count({}, function(err, numRounds) {
      if (err) return err;

      //first created round should be current
      var isCurrentRound = (numRounds == 0);
      var round = new Round({number: numRounds + 1, is_current: isCurrentRound});
      
      round.save(function(err, round) {
        if (err) return err;
        req.flash('notice', 'Round appended.');
        res.redirect('/rounds');
      });
    });
  });

  // load round from number
  app.param('roundNumber', function(req, res, next, number){
    Round
      .findOne({ number: number })
      .run(function(err, round) {
        if (err) return next(err); 
        if (!round) return next(new Error("Failed loading round " + number));
        req.round = round;
        next(); 
      });
  });

  //Delete round
  app.del('/round/:roundNumber', function(req, res){
    round = req.round;
    round.remove(function(err){
      req.flash('notice', 'Removed round');
      res.redirect('/rounds');
    });
  });

  //Get current round
  app.get('/rounds/current.:format?', function(req, res){
    Round
      .findOne({is_current: true})
      .run(function(err, round) {
        if (req.params.format == 'json') {
          res.contentType('application/json');
          res.send(JSON.stringify(round));
        }
        else 
        {
          res.render('rounds/current', {
            title: 'Current Round',
            round: round
          });   
        }
      });   
  });
};