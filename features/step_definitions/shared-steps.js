var sharedSteps = module.exports = function(){
  this.World = require('../support/world').World;

  this.Given(/^I am on the home page$/, function(next) {
    this.visit('/', next);
  });

  this.Then(/^I should see "([^"]*)"$/, function(text, next) {
    this.browser.text('body').should.include(text);
    next();
  });
}
