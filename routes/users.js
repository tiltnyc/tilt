var User = require('../models/user');

module.exports = function(app){

  // List of Users  
  app.get('/users', function(req, res){
    User
      .find({})
      .asc('username')
      .run(function(err, users) {
        res.render('users/index', {
          title: 'List of Users',
          users: users
        });
      });
  });

};