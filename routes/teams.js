var Team = require('../models/team');

module.exports = function(app){

  // List of Teams  
  app.get('/teams.:format?', function(req, res){
    Team
      .find({})
      .asc('name')
      .populate('users') 
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


  // New Team
  app.get('/teams/new', function(req, res){
    res.render('teams/new', {
      title: 'New Team'
    });
  });

  // Create Team
  app.post('/teams', function(req, res){
    team = new Team(req.body.team);
    team.save(function(err) {
      req.flash('notice', 'Created.');
      res.redirect('/team/' + team._id);
    });
  });

  // load user from ID parameter
  app.param('teamId', function(req, res, next, id){
    Team
      .findOne({ _id: id }, function(err, team) {
        if (err) return next(err);
        if (!team) return next(new Error("Failed loading team " + id));
        req.team = team;
        next(); 
      }).populate('users')  ;
  });

  // View Team
  app.get('/team/:teamId.:format?', function(req, res){
    if (req.params.format == 'json') {
      res.contentType('application/json');
      res.send(JSON.stringify(req.team));
    }
    else {
      res.render('teams/show', {
        title: req.team.name,
        team: req.team
      });
    }
  });

   // Edit team
  app.get('/team/:teamId/edit', function(req, res){
    res.render('teams/edit', {
      title: 'Edit '+req.team.name,
      team: req.team
    });
  });

  // Update team
  app.put('/teams/:teamId', function(req, res){
    team = req.team;

    if (req.body.team.name) team.name = req.body.team.name;

    team.save(function(err, doc) {
      if (err) throw err;
      req.flash('notice', 'Updated successfully');
      res.redirect('/team/' + team._id);
    });
  });

  //Delete team
  app.del('/team/:teamId', function(req, res){
    team = req.team;
    team.remove(function(err){
      req.flash('notice', 'Deleted');
      res.redirect('/teams');
    });
  });
  
}