this is the web application for tilt, which creates and manages a virtual market, with investment occuring within a series of rounds.  


#current status

* build: [![build status](https://secure.travis-ci.org/justinjmoses/tilt.png)](http://travis-ci.org/justinjmoses/tilt)

* story management in pivotal tracker: [https://www.pivotaltracker.com/projects/440359](https://www.pivotaltracker.com/projects/440359).

* production deployment: [http://tiltnyc.herokuapp.com/](http://tiltnyc.herokuapp.com/)


#developer requirements
* local installation of [mongodb (v2.0.2+)](http://www.mongodb.org/downloads).
* ensure xcode (os x) or other gcc compiler is available
* install `npm` package manager via `curl http://npmjs.org/install.sh | sh` (via [npmjs.org](http://npmjs.org/)) 
* install `n` [node version manager](https://github.com/visionmedia/n) via `npm install -g n`
    * install node >= v0.6.8 (for native heroku support, 0.6.15 is currently supported) - run `n 0.6.8` 

#installation
* clone source `git clone git@github.com:justinjmoses/tilt.git`
* run `npm install` (this downloads all dependencies into `node_modules`)
* install coffee globally if you haven't already via `npm install -g coffee-script`

#running
* ensure mongodb is running (`sudo mongod` )
* to run the app, simply run:
        
        coffee app

* to change the port:
        
        port=5000 coffee app
* alternatively, if you install foreman `npm install -g foreman`, you can run via foreman which will run using the web workers/dynos processes that heroku employs:

        foreman start


#tests
##installation
* in the root of the app, run `npm install -g cucumber`
* then run `npm install --dev` (see [cucumber.js docs](https://github.com/cucumber/cucumber-js))
* to run the cucumber integration tests, run 
        
        node_env=test port=3333 cucumber.js

