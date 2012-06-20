User = require("../models/user")
Transaction = require("../models/transaction")
Investment = require("../models/investment")
AuthHelpers = require("../helpers/auth_helpers")
RoundHelpers = require("../helpers/round_helpers")
SystemHelpers = require("../helpers/system_helpers")
UserHelpers = require("../helpers/user_helpers")
module.exports = (app) ->
  app.get "/user/dash", AuthHelpers.loggedIn, RoundHelpers.loadCurrentRound, (req, res) ->
    User.findOne(_id: req.user.id).populate("team").run (err, user) ->
      return SystemHandlers.error(req, res, err, "/")  if err
      UserHelpers.loadInvestments user, (err, investments) ->
        return SystemHandlers.error(req, res, err, "/")  if err
        user.investments = investments
        UserHelpers.loadTransactions user, (err, transactions) ->
          return SystemHandlers.error(req, res, err, "/")  if err
          user.transactions = transactions
          res.render "users/dash",
            title: "Dashboard"
            theUser: user
            currentRound: req.currentRound

  app.get "/users.:format?", AuthHelpers.restricted, (req, res) ->
    User.find({}).populate("team").asc("username").run (err, users) ->
      if req.params.format is "json"
        res.contentType "application/json"
        res.send JSON.stringify(users)
      else
        res.render "users/index",
          title: "List of Users"
          users: users

  app.get "/users/new", AuthHelpers.restricted, (req, res) ->
    res.render "users/new",
      title: "New User"

  app.post "/users", AuthHelpers.restricted, (req, res) ->
    req.body.user.team = null  if req.body.user.team is ""
    user = new User(req.body.user)
    user.save (err) ->
      req.flash "notice", "Created."
      res.redirect "/user/" + user._id

  app.param "id", (req, res, next, id) ->
    User.findOne(_id: req.params.id).populate("team").run (err, user) ->
      return next(err)  if err
      return next(new Error("Failed loading user " + id))  unless user
      req.theUser = user
      next()

  app.get "/user/:id.:format?", AuthHelpers.restricted, (req, res) ->
    Transaction.find(user: req.theUser._id).asc("round", "created").run (err, transactions) ->
      return  if err
      console.log transactions
      console.log req.theUser
      req.theUser.transactions = transactions
      Investment.find(user: req.theUser._id).populate("team").asc("round", "team.name").run (err, investments) ->
        return  if err
        req.theUser.investments = investments
        if req.params.format is "json"
          res.contentType "application/json"
          res.send JSON.stringify(req.theUser)
        else
          res.render "users/show",
            title: req.theUser.username
            theUser: req.theUser

  app.get "/user/:id/edit", AuthHelpers.restricted, (req, res) ->
    res.render "users/edit",
      title: "Edit " + req.theUser.username
      theUser: req.theUser

  app.put "/users/:id", AuthHelpers.restricted, (req, res) ->
    user = req.theUser
    user.username = req.body.user.username  if req.body.user.username
    user.email = req.body.user.email  if req.body.user.email
    
    if req.body.user.team isnt "" then user.addToTeam req.body.user.team
    
    user.save (err, doc) ->
      throw err  if err
      req.flash "notice", "Updated successfully"
      res.redirect "/user/" + user._id

  app.del "/user/:id", AuthHelpers.restricted, (req, res) ->
    user = req.theUser
    user.remove (err) ->
      req.flash "notice", "Deleted"
      res.redirect "/users"