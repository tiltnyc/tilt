Investment = require("../models/investment")

Math.roundToFixed = (num, dec) -> Math.round(num*100)/100; 

process = (user, array, round, callback) ->
  investments = []

  total = 0

  for inv in array
    inv.percentage = 0 unless 0 <= inv.percentage <= 1

    if total + inv.percentage >= 1 
      inv.percentage = Math.roundToFixed(1 - total, 2) #prevent over investment
    total += Math.roundToFixed inv.percentage, 2
    
  saveInvestment = (index, next) ->
    rowData = array[index]
    return next() unless rowData
    
    Investment.findOne
      round: round.number
      user: user
      team: rowData.team
    .run (err, investment) ->
      return next err if err
      investment ?= new Investment
        round: round.number
        user: user
        team: rowData.team
      investment.percentage = rowData.percentage
      investment.save (err) ->
        return next err if err
        investments.push investment
        saveInvestment index + 1, next
  
  saveInvestment 0, (err) -> callback err, investments

exports.investments = (investor, investments, round, done) ->
  process investor, investments, round, (err, i) -> done err, i