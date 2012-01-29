var Investment = require('../models/investment');

module.exports = function(app){

  // New investment
  app.get('/investment/new', function(req, res){
    res.render('investments/new', {
      title: 'New Investment'
    });
  });

  // Create User
  app.post('/investments.:format?', function(req, res){
    
    investment = new Investment(req.body.investment);
    
    investment.save(function(err) {
      //if (err) //throw error

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

 

  
};