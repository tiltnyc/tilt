var User = require('../models/user')
  , Transaction = require('../models/transaction')
  , Investment = require('../models/investment')
  , AuthHelpers = require('../helpers/auth_helpers');

module.exports = function(app){

  // List of Users  
  app.get('/users.:format?', AuthHelpers.restricted, function(req, res){
    User
    .find({})
      .populate('team')
      .asc('username')
      .run(function(err, users) {
        if (req.params.format == 'json') {
          res.contentType('application/json');
          res.send(JSON.stringify(users));
        }
        else {
          res.render('users/index', {
            title: 'List of Users',
            users: users
          });
        }
      });
  });

  // New User
  app.get('/users/new', AuthHelpers.restricted, function(req, res){
    res.render('users/new', {
      title: 'New User'
    });
  });

  // Create User
  app.post('/users', AuthHelpers.restricted, function(req, res) {
   
    //JM: Note - this is useless as the user is created without a password hash

    if (req.body.user.team == "") req.body.user.team = null;
    user = new User(req.body.user);
    
    user.save(function(err) {
      req.flash('notice', 'Created.');
      res.redirect('/user/' + user._id);
    });
  });

  // load user from ID parameter
  app.param('id', function(req, res, next, id){
    User
      .findOne({ _id: req.params.id })
      .populate('team')
      .run(function(err, user) {
        if (err) return next(err); 
        if (!user) return next(new Error("Failed loading user " + id));
        req.theUser = user;
        next(); 
      });
  });

  // View User
  app.get('/user/:id.:format?', AuthHelpers.restricted,function(req, res){
    
    Transaction
      .find({user: req.theUser._id})
      .asc('round', 'created')
      .run(function(err, transactions) {
        if (err) return;
        console.log(transactions);
        console.log(req.theUser);
        req.theUser.transactions = transactions;

        Investment
          .find({user: req.theUser._id})
          .populate('team')
          .asc('round', 'team.name')
          .run(function(err, investments) {
            if (err) return;
            req.theUser.investments = investments;
            
            if (req.params.format == 'json') {
              res.contentType('application/json');
              res.send(JSON.stringify(req.theUser));
            }
            else {
              res.render('users/show', {
                title: req.theUser.username,
                theUser: req.theUser
              });
            }   
          });
      });
  });

  // Edit User
  app.get('/user/:id/edit', AuthHelpers.restricted, function(req, res){
    res.render('users/edit', {
      title: 'Edit '+req.theUser.username,
      theUser: req.theUser
    });
  });

  // Update User
  app.put('/users/:id', AuthHelpers.restricted, function(req, res){
    user = req.theUser;

    if (req.body.user.username) user.username = req.body.user.username;
    if (req.body.user.email) user.email = req.body.user.email;
    if (user.team) user.oldTeam = user.team.id;
    
    user.team = (req.body.user.team != "") ? req.body.user.team : null;
    
    user.save(function(err, doc) {
      if (err) throw err;
      req.flash('notice', 'Updated successfully');
      res.redirect('/user/' + user._id);
    });
  });

  //Delete user
  app.del('/user/:id', AuthHelpers.restricted, function(req, res){
    user = req.theUser;
    user.remove(function(err){
      req.flash('notice', 'Deleted');
      res.redirect('/users');
    });
  });
 
};