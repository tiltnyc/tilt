Investor = require "../models/investor"

exports.loadInvestor = (req, res, next) ->
  return next() unless req.user and req.currentEvent
  Investor.findOne(event: req.currentEvent.id, user: req.user.id).populate("team").exec (err, investor) ->
    return next(err) if err
    if investor
      req.investor = investor 
      res.local('theInvestor', investor)
    next()