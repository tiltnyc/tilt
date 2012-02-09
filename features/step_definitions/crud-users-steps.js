var User = require('../../models/user');

module.exports = function(){
  this.World = require('../support/world').World;

  this.After(function(callback){
    this.clean(callback);
  });

  this.Given(/^I am an administrator$/, function(next) {
    //TODO
    next();
  }); 

  this.Given(/^there exists users:$/, function(table, next) {

    createUser(0, next);
    
    function createUser(index, callback) {
      if (table.hashes().length == index) return callback();
      var item = table.hashes()[index];
      new User({username: item.username, email: item.email}).save(function(err){
        if (err) return callback(err);
        return createUser(index+1, callback);
      });
    };
  });

  this.When(/^I go to the list of users$/, function(next) {
    this.visit('/users', next);
  });

  this.When(/^I go to create a new user$/, function(next) {
    this.visit('/users/new', next);
  });

  this.When(/^I enter "([^"]*)" as the "([^"]*)"$/, function(value, field, next) {
    this.browser.fill(field, value, next);
  });

  this.When(/^I click "([^"]*)"$/, function(button, callback) {
    this.browser.pressButton(button, callback);
  });

  this.When(/^I click the link "([^"]*)" for user "([^"]*)"$/, function(link, username, callback) {
    this.browser.onconfirm(function(text){ return true; });
    this.browser.clickLink("tr:contains(" + username + ") a:contains(" + link +")", callback);
  });

};