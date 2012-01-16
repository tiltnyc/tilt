This is the web application for tilt, coming in april twenty twelve. 

#Requirements
* Local installation of [mongodb (v2.0.2+)](http://www.mongodb.org/downloads).
* Install `npm` package manager via `curl http://npmjs.org/install.sh | sh` (via [npmjs.org](http://npmjs.org/)) 
* Install `n` [node version manager](https://github.com/visionmedia/n) via `npm install -g n`
    * install node v0.4.7 (for native heroku support) - run `n 0.4.7` 

#Installation
* clone source `git clone git@github.com:justinjmoses/tilt.git`
* run `npm install` (this downloads all dependencies into `node_modules`)
* execute `node app.js` to start server (port 3000 by default).

#Running
* to run the app, simply run:
    node app.js
* alternatively, to change the port:
    PORT=5000 node app.js

#Tests
* to run the cucumber integration tests, run 
    NODE_ENV=test PORT=3333 cucumber.js

