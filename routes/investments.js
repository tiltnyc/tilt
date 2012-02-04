var Investment = require('../models/investment')
    , Team = require('../models/team')
    , User = require('../models/user');

module.exports = function(app){

  // New investment
  app.get('/investment/new', function(req, res){
    Team
      .find({})
      .asc('name') 
      .run(function(err, teams) {
        res.render('investments/new', {
          title: 'New Investment',
          teams: teams
        });   
      });   
  });

  // Perform an investment
  app.post('/investments.:format?', function(req, res){
    
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
      var round = req.body.investment.round;

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
          var investment = new Investment({
              round: round
            , user: user
            , team: rowData.team
            , amount: rowData.percentage 
          });

          investment.save(function(err) {
            if (err) callback(err); 
            else { 
              investments.push(investment);
              saveInvestment(array, index+1, callback);
            }
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