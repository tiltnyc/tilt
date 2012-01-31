require('./db_connect');

var Investment = new Schema({
  amount      : {type: Number, required: true},
  user        : {type: Schema.ObjectId, ref: 'User'},
  round       : {type: Number},
  team        : {type: Schema.ObjectId, ref: 'Team'}, 
  created_at  : {type : Date, default : Date.now},
  updated_at  : {type : Date, default : Date.now}
});

var Transaction = require('./transaction');

//on save: add transaction
Investment.pre('save', function (next) {
  var investment = this; 

  new Transaction({amount: -(this.amount), user: this.user, label: "round " + this.round + " investment"}).save(function(err) {
    if (err) return next(err);
    else return next();
  });
});

//on save: update team investment

var exports = module.exports = mongoose.model('Investment', Investment);