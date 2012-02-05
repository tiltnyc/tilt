var Round = require('../models/round');

/*
 * GET home page.
 */

module.exports = function(app){

  app.get('/', function(req, res){
    
    res.render('index', {
      title: 'tilt',
      currentRound: round 
    });   

  });
};