var User = require('../../models/user');

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
     this.browser.clickLink(link, callback);
     callback();
     //this.browser.evaluate("$('a[title=\"delete\"]').click()");  
  });

  //JM: this should go into an after scenario hook once that is implemented in cucumber-js  
  this.Then(/^the database should be cleaned$/, function(next) {
    this.clean(next);
  });

};