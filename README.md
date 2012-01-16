This is the web application for tilt, coming in april twenty twelve. 

#Requirements
* Local installation of [mongodb (v2.0.2+)](http://www.mongodb.org/downloads).
* Install `npm` package manager via `curl http://npmjs.org/install.sh | sh` (via [npmjs.org](http://npmjs.org/)) 
* `n` [node version manager](https://github.com/visionmedia/n)
    * install node v0.4.7 (heroku support), run `n 0.4.7` 

#Installation
* clone source
* run `npm install` (this downloads all dependencies into `node_modules`)
* `node app.js` to start server

#Running
* to run the app, simply run
    node app.js
* alternatively, to change PORT
    PORT=5000 node app.js

#Tests
* to run the cucumber integration tests, run 
    NODE_ENV=test PORT=3333 cucumber.js

