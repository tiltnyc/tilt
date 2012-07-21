#some source courtesy of https://github.com/twilson63/cakefile-template
fs = require 'fs'
{print} = require 'util'
{spawn, exec} = require 'child_process'

try
  which = require('which').sync
catch err
  which = null

# ANSI Terminal Colors
bold = `'\033[0;1m'`
green = `'\033[0;32m'`
reset = `'\033[0m'`
red = `'\033[0;31m'`

# Internal Functions
#
# ## *walk* 
#
# **given** string as dir which represents a directory in relation to local directory
# **and** callback as done in the form of (err, results)
# **then** recurse through directory returning an array of files
walk = (dir, done) ->
  results = []
  fs.readdir dir, (err, list) ->
    return done(err, []) if err
    pending = list.length
    return done(null, results) unless pending
    for name in list
      file = "#{dir}/#{name}"
      try
        stat = fs.statSync file
      catch err
        stat = null
      if stat?.isDirectory()
        walk file, (err, res) ->
          results.push name for name in res
          done(null, results) unless --pending
      else
        results.push file
        done(null, results) unless --pending

log = (message, color, explanation) -> console.log color + message + reset + ' ' + (explanation or '')

#uses child_process.spawn
launch = (cmd, options=[], env=process.env, callback) ->
  cmd = which(cmd) if which
  app = spawn cmd, options, env
  app.stdout.pipe(process.stdout)
  app.stderr.pipe(process.stderr)
  app.on 'exit', (status) -> callback?() if status is 0

testenv = ->
  custom_env = process.env
  custom_env.PORT = 3333
  custom_env.NODE_ENV = "test" 
  custom_env

#run unit test 
#JM: to use child_process.spawn, files must be passed as list rather than wildcard match
task 'mocha', 'run unit tests', -> 
  log "running unit tests...", bold 
  exec 'NODE_ENV=test ./node_modules/mocha/bin/mocha --compilers coffee:coffee-script --colors test/**/*.spec.coffee', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

#run cucumber tests
task 'cuke', 'run integration tests', ->
  log "running integration tests...", bold
  
  launch './node_modules/cucumber/bin/cucumber.js', [], testenv(), (err) ->
    throw err if err 
 