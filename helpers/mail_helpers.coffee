SendGrid = require('sendgrid').SendGrid;
sendgrid = new SendGrid(process.env.SENDGRID_USERNAME, process.env.SENDGRID_PASSWORD)

exports.send = (to, from, subject, body, bcc = []) ->
  if to instanceof Array
    [to, toName] = to
  else
    fromName = ""
  if from instanceof Array
    [from, fromName] = from
  else 
    fromName = ""
  sendgrid.send
    to: to
    toname: toName
    from: from
    fromname: fromName
    subject: subject
    text: body
    bcc: bcc
  , (success, msg) ->
    console.log msg if !success  