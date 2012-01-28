var Team = require('../models/team');

module.exports = function(app){

  // List of Teams  
  app.get('/teams.:format?', function(req, res){
    Team
      .find({})
      .asc('name')
      .run(function(err, teams) {
        if (req.params.format == 'json') {
          res.contentType('application/json');
          res.send(JSON.stringify(teams));
        }
        else {
          res.render('teams/index', {
            title: 'List of Teams',
            teams: teams
          });
        }
      });
  }); 
}