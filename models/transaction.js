require('./db_connect');

var Transaction = new Schema({
  amount      : {type: Number, required: true},
  user        : {type: Schema.ObjectId, ref: 'User', required: true},
  round       : {type: Number, required: true},
  label       : {type: String},
  created_at  : {type : Date, default : Date.now},
  updated_at  : {type : Date, default : Date.now}
});

var User = require('./user');

//on save: update user's funds
Transaction.pre('save', function (next) {
  var transaction = this;
  User
    .findOne({ _id: this.user }, function(err, user) {
      if (err) return next(err); 

      //required to dirty the array
      var funds = user.funds.concat();
      funds[transaction.round - 1] += transaction.amount;
      user.funds = funds;
    
      user.save(function(err) {
        if (err) return next(err);
        else return next();
      });  
    });
});

var exports = module.exports = mongoose.model('Transaction', Transaction);