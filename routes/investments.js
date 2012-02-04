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

  // Create User
  app.post('/investments.:format?', function(req, res){
    
    investment = new Investment(req.body.investment);
    
    if (req.user) investment.user = req.user;
    
    if (!investment.user) return handleError(req, res, "Invalid User", "/investment/new");

    investment.save(function(err) {
      if (err) return handleError(req, res, err, '/investment/new');
        
      if (req.params.format == 'json') {
          res.contentType('application/json');
          res.send(JSON.stringify(investment));
      }
      else {
        req.flash('notice', 'Invested.');
        res.redirect('/');
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