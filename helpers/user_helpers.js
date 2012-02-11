var User = require('../models/user')
  , Investment = require('../models/investment')
  , Transaction = require('../models/transaction');

exports.loadInvestments = function(user, next) {
  Investment
    .find({user: user._id})
    .populate('team')
    .asc('round', 'team.name')
    .run(function(err, investments) {
      if (err) return next(err);
      next(null, investments);
    });
};

exports.loadTransactions = function(user, next) {
  Transaction
    .find({user: user._id})
    .asc('round', 'created')
    .run(function(err, transactions) {
      if (err) return next(err);
      next(null, transactions);
    });
}