User = require "../models/user"
Team = require "../models/team"
Event = require "../models/event"
Round = require "../models/round"
Competitor = require "../models/competitor"

nouns = ["fox", "lion", "ball", "street", "tree", "cat", "bird"]
verbs = ["jump", "talk", "look", "walk", "growl", "think", "swallow", "mentor"]

randomWordPair = (seperator = " ") ->
  nouns[Math.randomIntTo(nouns.length)] + seperator + verbs[Math.randomIntTo(verbs.length)]

create = (Model, props, done) ->
  instance = new Model props
  instance.save (err) ->
    throw err if err
    done instance
  instance

createLoop = (Model, count, props, done) ->
  created = []

  doCreate = (i, callback) ->
    propIns = {}
    for key, value of props
      propIns[key] = if value instanceof Function then value(i) else value 
    create Model, propIns, (result) -> callback result 

  doneCount = 1
  for i in [1..count] 
    created.push doCreate i-1, () ->
      done(created) if doneCount++ is count 

starter = (count, done) ->
  roundNbr = 1
  create Event, {name: randomWordPair(), date: new Date()}, (event) ->
    createLoop User, count,  
      name: () -> randomWordPair()
      email: () -> randomWordPair("_")+"@example.com" 
    , (users) ->
      createLoop Competitor, count, 
        user: (i) -> users[i]
        event: event
      , (competitors) ->   
        createLoop Team, count, 
          name: () -> randomWordPair()
          event: event
        , (teams) ->  
          createLoop Round, count,
            number: () -> roundNbr++ 
            event: event
          , (rounds) ->
            done
              event: event
              users: users
              competitors: competitors
              teams: teams
              rounds: rounds

module.exports = 
  create: create
  starter: starter