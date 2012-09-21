Investment = require("../models/investment")

process = (user, array, round, callback) ->
  investments = []
  teams = [] #track dupes
  total = 0

  return callback 'cannot invest, this round is not open' unless round.is_open

  for inv, i in array
    if teams.indexOf(inv.team) >= 0
      array[i] = undefined #remove dups if any
      break
    else teams.push(inv.team)

    inv.percentage = 0 unless 0 <= inv.percentage <= 1
    if total + inv.percentage >= 1
      inv.percentage = Math.roundToFixed(1 - total, 2) #prevent over investment
    total += Math.roundToFixed inv.percentage, 2

  saveInvestment = (index, next) ->
    rowData = array[index]
    return next() unless rowData

    Investment.findOne {
      round: round.id
      competitor: user.id
      team: rowData.team
    }, (err, investment) ->
      return next err if err
      investment ?= new Investment
        round: round.id
        competitor: user.id
        team: rowData.team
        event: round.event
      investment.percentage = rowData.percentage
      investment.save (err) ->
        return next err if err
        investments.push investment
        saveInvestment index + 1, next

  saveInvestment 0, (err) -> callback err, investments

exports.investments = (investor, investments, round, done) ->
  process investor, investments, round, (err, i) -> done err, i
