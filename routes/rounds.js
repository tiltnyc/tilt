var Round = require('../models/round'),
    User = require('../models/user'),
    Transaction = require('../models/transaction'),
    Investment = require('../models/investment');

module.exports = function(app){
  var redirect = '/rounds';

  // Rounds control
  app.get(redirect, function(req, res){
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
  app.post(redirect, function(req, res) {
    Round.count({}, function(err, numRounds) {
      if (err) return err;

      //first created round should be current
      var isCurrentRound = (numRounds == 0);
      var round = new Round({number: numRounds + 1, is_current: isCurrentRound});
      
      round.save(function(err, round) {
        if (err) return err;
        req.flash('notice', 'Round appended.');
        res.redirect(redirect);
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
      res.redirect(redirect);
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

  //Toggle round open/close, or current round
  app.put('/round/:roundNumber', function(req, res){
    var round = req.round;
    if (req.body.round.is_open) round.is_open = (req.body.round.is_open.toLowerCase() === 'true');
    if (req.body.round.next_round) {
      round.is_current = false;
      round.is_open = false;
    }

    round.save(function(err){
      if (err) return handleError(req, res, err, redirect);
      
      if (req.body.round.next_round) {
        Round.
          findOne({number: req.round.number + 1}).
          run(function(err, round){
            if (err) return handleError(req, res, err, redirect);
            if (!round) return handleError(req, res, "no round found.", redirect);

            round.is_current = true;
            round.save(function(err) {
              if (err) return handleError(req, res, err, redirect);

              req.flash('notice', 'Round progressed.');
              res.redirect(redirect);
            })
          });
      }
      else
      {
        req.flash('notice', 'Round toggled.');
        res.redirect(redirect);
      }
    });
  });

  //Process a round
  app.put('/round/:roundNumber/process', loadFirstRound, function(req, res){
    var round = req.round
      ,results = {}
      , total = 0
      , investerList = [];

    if (round.processed) return handleError(req, res, "cannot process again.", redirect);

    Investment.
      find({round: round.number}).
      populate('user').populate('team').
      run(function(err, investments){
      
        investments.forEach(function(investment){
          var teamEntry = results[investment.team.id] || 0;
          var userInvested = investment.percentage * investment.user.funds[round.number - 1];
          //console.log('invested: ' + userInvested.toString());
          results[investment.team.id] = teamEntry += userInvested;  
          total += userInvested;
          if (investerList.indexOf(investment.user.id) < 0) investerList.push(investment.user.id);
        });          

        var average = total / investerList.length
          , averagePercentage = average / total
          , cumulativeDistanceFromAverage = 0
          , factor = (round.number == 1) ? 1 : total / req.firstRound.total_funds; //factor: how significant this is compared to first round

        console.log(results);
        console.log('total Invested: '+total);
        console.log('average Investment: '+average);
        console.log('average As Percentage: '+averagePercentage);
        console.log('number of investors: '+investerList.length)
        console.log('factor: '+factor);


        for (var team in results) {
          var teamPercentage = results[team] / total
            , teamPriceMovement = ((teamPercentage - averagePercentage) * factor);
                      
          cumulativeDistanceFromAverage += Math.abs(teamPercentage - averagePercentage);
  
          console.log('team: ' + team + ' got: ' + teamPercentage);
          console.log('resulting in: ' + teamPriceMovement.toFixed(2));
          //todo: set team share price
            //get team
            //var before_price = team.last_price;
            //team.last_price += teamPriceMovement;
            //team.movement = teamPriceMovement / before_price; 
            //team.save(...)
              //new Price({team: team, before_price: before_price, after_price: team.last_price, round: round });
                //price.save(...)  
        };

        round.standard_deviation = cumulativeDistanceFromAverage / investerList.length;
        round.total_funds = total;
        round.investor_count = investerList.length;

        
        
        console.log('sd= ' + round.standard_deviation);

        round.is_open = false;
        round.save(function(err){
          if (err) return handleError(req, res, err, redirect);

          req.flash('notice', 'Round ' + round.number.toString() + ' processed.');
          res.redirect(redirect);        
        });

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
          if (err) return handleError(req, res, err, redirect);
          self.resume();
      });  
    })

    var errorMode = false; 
    stream.on('error', function (err) {
      req.flash('error', 'Error allocating funds.');
      res.redirect(redirect);
      this.destroy();
    });

    stream.on('close', function () {
      //now update the round
      round.allocated += amount;

      round.save(function(err){
        if (err) {
          handleError(req, res, err, redirect); //TODO: should really undo all user updates above via a transaction
        } 
        else {
          req.flash('notice', 'Allocated funds to all users for round ' + req.round.number.toString() + '.');
          res.redirect(redirect);
        }
      });
    });
  });

  function loadFirstRound(req, res, next) {
     Round.findOne({number: 1}).run(function(err, round){
        if (err) return next(err);
        req.firstRound = round;
        next();
     });
  }

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