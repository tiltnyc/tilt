Investment = require("../models/investment")
Transaction = require("../models/transaction")
User = require("../models/user")
Team = require("../models/team")
Round = require("../models/round")
Result = require("../models/result")

reset = (done) ->
  options = multi: true
  Transaction.find({}).remove (err) ->
    return done err if err
    Investment.find({}).remove (err) ->
      return done err if err
      Result.find({}).remove (err) ->
        return done err if err
        User.update {},
          $set:
            funds: []
        , options, (err) ->
          return done err if err
          Team.update {},
            $set:
              movement: 0
              last_price: 1.00
              movement_percentage: 0
          , options, (err) ->
            return done err if err
            Round.update {},
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
              Round.findOne(number: 1).update
                $set:
                  is_current: true
              , (err) -> done err

module.exports = 
  process: reset