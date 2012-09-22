Investment = require("../models/investment")
Transaction = require("../models/transaction")
Investor = require("../models/Investor")
Team = require("../models/team")
Round = require("../models/round")
Result = require("../models/result")

reset = (event, done) ->
  options = multi: true
  Transaction.find(event: event.id).remove (err) ->
    return done err if err
    Investment.find(event: event.id).remove (err) ->
      return done err if err
      Result.find(event: event.id).remove (err) ->
        return done err if err
        Investor.update {},
          $set:
            funds: []
        , options, (err) ->
          return done err if err
          Team.update {event: event.id},
            $set:
              movement: 0
              last_price: 1.00
              movement_percentage: 0
          , options, (err) ->
            return done err if err
            Round.update {event: event.id},
              $set:
                is_open: false
                is_current: false
                total_funds: 0
                allocated: 0
                factor: 1
                investor_count: 0
                average: 0
              $unset:
                standard_deviation: 1
            , options, (err) ->
              return done err if err
              Round.update {event: event.id, number: 1}, {$set: is_current: true}, (err) -> done err

module.exports = 
  process: reset