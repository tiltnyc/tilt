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

  // New User
  app.get('/users/new', function(req, res){
    res.render('users/new', {
      title: 'New User'
    });
  });

  // Create User
  app.post('/users', function(req, res){
    user = new User(req.body.user);
    user.save(function(err) {
      req.flash('notice', 'Created.');
      res.redirect('/user/' + user._id);
    });
  });

  // load user from ID parameter
  app.param('id', function(req, res, next, id){
    User
      .findOne({ _id: req.params.id }, function(err, user) {
        if (err) return next(err);
        if (!user) return next(new Error("Failed loading user " + id));
        req.user = user;
        next(); 
      });
  });

  // View User
  app.get('/user/:id', function(req, res){
    res.render('users/show', {
      title: req.user.username,
      user: req.user
    });
  });

  // Edit User
  app.get('/user/:id/edit', function(req, res){
    res.render('users/edit', {
      title: 'Edit '+req.user.username,
      user: req.user
    });
  });

  // Update User
  app.put('/users/:id', function(req, res){
    user = req.user;

    if (req.body.user.username) user.username = req.body.user.username;
    if (req.body.user.email) user.email = req.body.user.email;

    user.save(function(err, doc) {
      if (err) throw err;
      req.flash('notice', 'Updated successfully');
      res.redirect('/user/' + user._id);

    });
  });

  app.del('/user/:id', function(req, res){
    user = req.user;
    user.remove(function(err){
      req.flash('notice', 'Deleted');
      res.redirect('/users');
    });
  });
  
};