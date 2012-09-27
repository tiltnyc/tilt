User = require "../models/user"
Team = require "../models/team"
Event = require "../models/event"
Round = require "../models/round"
Competitor = require "../models/competitor"
Investor = require "../models/investor"

nouns = ["fox", "lion", "ball", "street", "tree", "cat", "bird", "pimple", "drug"]
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
  counts = 
    users: count?.users ? count
    competitors: count?.competitors ? count
    investors: count?.investors ? count
    teams: count?.teams ? count
    rounds: count?.rounds ? count    
  roundNbr = 1
  create Event, {name: randomWordPair(), date: new Date()}, (event) ->
    createLoop User, counts.users,  
      name: () -> randomWordPair()
      email: () -> randomWordPair("_")+"#{Math.random()}@example.com" 
    , (users) ->
      createLoop Competitor, counts.competitors, 
        user: (i) -> users[i]
        event: event
      , (competitors) -> 
        createLoop Investor, counts.investors, 
          user: (i) -> users[i]
          event: event
        , (investors) ->  
          createLoop Team, counts.teams, 
            name: () -> randomWordPair()
            event: event
          , (teams) ->  
            createLoop Round, counts.rounds,
              number: () -> roundNbr++ 
              event: event
            , (rounds) ->
              done
                event: event
                users: users
                competitors: competitors
                investors: investors
                teams: teams
                rounds: rounds

module.exports = 
  create: create
  starter: starter