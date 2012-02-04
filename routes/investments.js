var Investment = require('../models/investment')
    , Team = require('../models/team');

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

    if (!user) return handleError(req, res, "Invalid User", "/investment/new");
    
    var investments = [];

    err = saveInvestment(req.body.investment, 0, function(err){
      if (err) return handleError(req, res, "Error saving investment in team " + req.body.investment[prop].team, "/investment/new");      
      
      req.flash('notice', 'Invested.');
      res.redirect('/');
    });
            
    function saveInvestment(data, index, callback) {
      var rowData;
      if (rowData = data['team_' + index]) { 
        var investment = new Investment({
            round: data.round
          , user: user
          , team: rowData.team
          , amount: rowData.percentage 
        });

        investment.save(function(err) {
          console.log('save with: ' + err);

          if (err) callback(err); 
          else return saveInvestment(data, index+1, callback);
        });
        
      } else callback();
    }  
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