SendGrid = require('sendgrid').SendGrid;
sendgrid = new SendGrid(process.env.SENDGRID_USERNAME, process.env.SENDGRID_PASSWORD)

exports.send = (to, from, subject, body) ->
  sendgrid.send
    to: to
    from: from
    subject: subject
    text: body
  , (success, msg) ->
    console.log msg if !success  