  var zombie = require('zombie')
  , HTML5  = require('html5')
  , should = require('should')
  , server = require('../../app')
  , databaseCleaner = require('database-cleaner')
  , dbCleaner = new DatabaseCleaner('mongodb');

exports.World = function(callback){
  this.browser = new zombie.Browser({runScripts:true, debug:false, htmlParser: HTML5});
 
  this.page = function(path){
   return "http://localhost:" + server.address().port + path
  };

  this.visit = function(path, callback){
    this.browser.visit( this.page(path), function(err, browser, status){
      callback(err, browser, status);
    });
  };

  this.clean = function(callback){
     dbCleaner.clean(mongoose.connection.db, callback);
  }

  callback(this);
};
