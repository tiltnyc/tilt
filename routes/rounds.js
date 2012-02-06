var Round = require('../models/round'),
    User = require('../models/user'),
    Transaction = require('../models/transaction');

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

  //Allocate funds to round
  app.post('/round/:roundNumber/allocate', function(req, res){

    var stream = User.find().stream();
    var round = req.round;
    var amount = new Number(req.body.allocate.amount);
    var number = round.number;

    stream.on('data', function (user) {
      this.pause();
      var self = this;
      new Transaction({amount:amount, round: number, user: user.id, label: 'round ' + number.toString() + ' allocation.'}).
        save(function(err, doc) {
          if (err) return handleError(req, res, err, '/rounds');
          self.resume();
      });  
    })

    var errorMode = false; 
    stream.on('error', function (err) {
      req.flash('error', 'Error allocating funds.');
      res.redirect('/rounds');
      this.destroy();
    });

    stream.on('close', function () {
      //now update the round
      round.total_funds += amount;

      round.save(function(err){
        if (err) {
          handleError(req, res, err, '/rounds'); //TODO: should really undo all user updates above via a transaction
        } 
        else {
          req.flash('notice', 'Allocated funds to all users for round ' + req.round.number.toString() + '.');
          res.redirect('/rounds');
        }
      });
    });
  });

  function handleError(req, res, error, redirect) {
    if (req.params.format == 'json') {
      res.contentType('application/json');
      res.send(JSON.stringify({error: error}));
    } else {
      req.flash('error', error);
      res.redirect(redirect);
    }
  }
};