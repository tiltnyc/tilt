var Investment = require('../models/investment')
    , Team = require('../models/team')
    , User = require('../models/user')
    , Round = require('../models/round')
    , RoundHelpers = require('../helpers/round_helpers')
    , AuthHelpers = require('../helpers/auth_helpers')
    , TeamHelpers = require('../helpers/team_helpers')
    , SystemHelpers = require('../helpers/system_helpers');
         

module.exports = function(app){

  // New investment
  app.get('/investment/new', AuthHelpers.loggedIn, RoundHelpers.loadCurrentRound, function(req, res){
    TeamHelpers.getUserInvestable(req.user, function(err, teams) {
        if (err) return SystemHelpers.error(req, res, err);

         res.render('investments/new', {
          title: 'New Investment',
          teams: teams,
          currentRound: req.currentRound
        });   
      }); 
  });

  // Perform an investment
  app.post('/investments.:format?', AuthHelpers.loggedIn, RoundHelpers.loadCurrentRound, function(req, res){

    //temp -for adam    
    console.log(req.body);

    //only admins can submit user in request
    if (req.body.investment.user && !req.user.is_admin) return handleError(req, res, 'Not authorized.', '/');

    var user = req.body.investment.user || req.user;

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

          if (req.user.is_admin) res.redirect('/investment/new');
          else res.redirect('/user/dash');
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
  
};