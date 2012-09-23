connectStreamS3 = require 'connect-stream-s3'
amazon = require('awssum').load 'amazon/amazon'

exports.error = (req, res, error, redirect) ->
  if req.params.format is "json"
    res.contentType "application/json"
    res.send JSON.stringify(error: error)
  else
    req.flash "error", error
    res.redirect redirect

exports.uniquifyObjectNames = (folder) ->
  folder = if folder then folder + "/" else ""
  (req, res, next) ->
    for key, value of req.files
      req.files[key].s3ObjectName = "#{folder}#{new Date().getTime()}_#{req.files[key].name}"
    next()

exports.uploader = connectStreamS3
    accessKeyId     : process.env.S3_KEY,
    secretAccessKey : process.env.S3_SECRET,
    awsAccountId    : process.env.AWS_ACCOUNT_ID,
    region          : amazon.US_EAST_1,
    bucketName      : 'tiltnyc',
    concurrency     : 2

exports.getImageURIs = (req) ->
  base = "https://s3.amazonaws.com/tiltnyc/"
  (base + value.s3ObjectName for key, value of req.files)