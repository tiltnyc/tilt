{should, clean} = require "../test-base"

Transaction = require "../../models/transaction"
User = require "../../models/user"
  
describe "Trasaction", ->
  user = undefined

  beforeEach (done) ->
    user = new User
      username: 'justin'
      email: 'justin@example.com'
    .save (err) ->
      throw err if err
      done()

  afterEach (done) ->
    clean done

  it "on save, modifies funds to user for specified round", (done) ->
    transaction = new Transaction
      user: user._id

    done()
  
  #create user 
  #create transaction 
  #save