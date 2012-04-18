This is the web application for tilt, coming in april twenty twelve. 

[![Build Status](https://secure.travis-ci.org/justinjmoses/tilt.png)](http://travis-ci.org/justinjmoses/tilt)

#Status
Story management in Pivotal Tracker: [https://www.pivotaltracker.com/projects/440359](https://www.pivotaltracker.com/projects/440359).



#Requirements
* Local installation of [mongodb (v2.0.2+)](http://www.mongodb.org/downloads).
* Ensure XCode (OS X) or other gcc compiler is available
* Install `npm` package manager via `curl http://npmjs.org/install.sh | sh` (via [npmjs.org](http://npmjs.org/)) 
* Install `n` [node version manager](https://github.com/visionmedia/n) via `npm install -g n`
    * install node >= v0.6.8 (for native heroku support, 0.6.15 is currently supported) - run `n 0.6.8` 

#Installation
* clone source `git clone git@github.com:justinjmoses/tilt.git`
* run `npm install` (this downloads all dependencies into `node_modules`)
* execute `node app.js` to start server (port 3000 by default).

#Running
* ensure mongodb is running (`sudo mongod` )
* to run the app, simply run:
        
        node app.js

* to change the port:
        
        PORT=5000 node app.js
* alternatively, if you install foreman `npm install -g foreman`, you can run via foreman which will run using the web workers/dynos processes that Heroku employs:

        foreman start


#Tests
##Installation
* in the root of the app, run `npm install -g cucumber`
* then run `npm install --dev` (see [cucumber.js docs](https://github.com/cucumber/cucumber-js))
* to run the cucumber integration tests, run 
        
        NODE_ENV=test PORT=3333 cucumber.js

