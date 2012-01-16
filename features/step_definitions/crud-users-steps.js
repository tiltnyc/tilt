var User = require('../../models/user');

var DatabaseCleaner = require('database-cleaner')
  , databaseCleaner = new DatabaseCleaner('mongodb');

module.exports = function(){
  this.World = require('../support/world').World;

  this.Given(/^I am an administrator$/, function(next) {
    //TODO
    next();
  }); 

  this.Given(/^there exists users:$/, function(table, next) {
    table.hashes().forEach(function(item) {
      new User({username: item.username, email: item.email}).save();   
    });
    
    next();   
  });

  this.When(/^I visit the list of users$/, function(next) {
    // express the regexp above with the code you wish you had
    this.visit('/users', next);
  });

  this.Then(/^the database should be cleaned$/, function(next) {
    //JM: this should go into an after scenario hook once that is implemented in cucumber-js
    databaseCleaner.clean(mongoose.connection.db, next);
  });
};