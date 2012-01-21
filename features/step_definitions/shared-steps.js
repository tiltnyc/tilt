var sharedSteps = module.exports = function(){
  this.World = require('../support/world').World;

  this.Given(/^I am on the home page$/, function(next) {
    this.visit('/', next);
  });

  this.Then(/^I should see "([^"]*)"$/, function(text, next) {
    this.browser.text('body').should.include(text);
    next();
  });

  this.Then(/^I should not see "([^"]*)"$/, function(text, next) {
    console.log(this.browser.location._url);  
    this.browser.viewInBrowser(); 

    //this.browser.text('body').should.not.include(text);
   //  next();
  });
}
