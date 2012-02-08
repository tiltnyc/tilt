var Investment = require('../models/investment')
    , Team = require('../models/team')
    , User = require('../models/user')
    , Round = require('../models/round');

module.exports = function(app){

  // New investment
  app.get('/investment/new', loadCurrentRound, function(req, res){
    Team
      .find({})
      .asc('name') 
      .run(function(err, teams) {
        res.render('investments/new', {
          title: 'New Investment',
          teams: teams,
          currentRound: req.currentRound
        });   
      });   
  });

  // Perform an investment
  app.post('/investments.:format?', loadCurrentRound, function(req, res){
    
    var user = req.user || req.body.investment.user;

    if (!user) return handleError(req, res, "invalid user", "/investment/new");

    user = User.findOne({ _id: user._id || user }).run(function(err, user){
      
      if (err) return handleError(req, res, "invalid user", "/investment/new");

      //handle different input between JSON and HTML
      if (!req.body.investment.investments) {
        req.body.investment.investments = []; 
        for (var prop in req.body.investment) {
          if (prop.substring(0,5) == 'team_') 
            req.body.investment.investments[prop.split('_')[1]] = req.body.investment[prop];
        }
      }

      var investments = [];
      var round = req.currentRound;

      if (!round)
        return handleError(req, res, "no current round.", "/investment/new")
      else if (!round.is_open)
        return handleError(req, res, "cannot invest - round no longer open.", "/investment/new")
      
      err = saveInvestment(req.body.investment.investments, 0, function(err){
        if (err) return handleError(req, res, err, "/investment/new");      
        
        if (req.params.format == 'json') {
          res.contentType('application/json');
          res.send(JSON.stringify(investments));
        } else {
          req.flash('notice', 'invested successfully.');
          res.redirect('/');
        }
      });
              
      function saveInvestment(array, index, callback) {
        var rowData;
        if (rowData = array[index]) { 
          Investment.
            findOne({round: round.number, user: user, team: rowData.team}).
            run(function(err, investment){
              if (!investment) {
                investment = new Investment({
                    round: round.number
                  , user: user
                  , team: rowData.team
                });
              } 
              
              investment.percentage = rowData.percentage;

              investment.save(function(err) {
                if (err) callback(err); 
                else { 
                  investments.push(investment);
                  saveInvestment(array, index+1, callback);
                }
              });

            }); 
        } else callback();
      }   

    });
    
  });

  //TODO: move into something more generic
  function handleError(req, res, error, redirect) {
    if (req.params.format == 'json') {
      res.contentType('application/json');
      res.send(JSON.stringify({error: error}));
    } else {
      req.flash('error', error);
      res.redirect(redirect);
    }
  }

  function loadCurrentRound(req, res, next) {
    Round
      .findOne({is_current: true})
      .run(function(err, round) {
        if (err) return next(err);
        req.currentRound = round;
        next();
      });
  }
  
};