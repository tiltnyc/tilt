var zombie = require('zombie')
  , HTML5  = require('html5')
  , should = require('should')
  , server = require('../../app');

var World = module.exports = function(){
  this.browser = new zombie.Browser({runScripts:true, debug:false, htmlParser: HTML5});

  this.page = function(path){
   return "http://localhost:" + server.address().port + path
  };

  this.visit = function(path, callback){
    this.browser.visit( this.page(path), function(err, browser, status){
      callback(err, browser, status);
    });
  };
};
