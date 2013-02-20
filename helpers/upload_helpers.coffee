connectStreamS3 = require 'connect-stream-s3'
amazon = require('awssum').load 'amazon/amazon'
im = require('imagemagick')
fs = require 'fs'

exports.uniquifyObjectNames = (folder) ->
  folder = if folder then folder + "/" else ""
  (req, res, next) ->
    for key, value of req.files
      req.files[key].s3ObjectName = "#{folder}#{new Date().getTime()}_#{req.files[key].name}"
    next()

exports.resizeImages = (width = 100) ->
  (req, res, next) ->
    fileKeys = Object.keys req.files
    suffix = "_resize"
    process = (i, done) ->
      return done() if i >= fileKeys.length 
      file = req.files[fileKeys[i]]
      return process i+1, done unless file and file.size 
      im.resize 
        srcPath: file.path 
        dstPath: file.path+suffix 
        width:   width
      , (err, stdout, stderr) ->
        if err
          console.log err
          return next err
        file.path += suffix
        fs.stat file.path, (err, stat) ->
          file.size = stat.size
          process i+1, done

    process 0, () -> next()

exports.uploader = connectStreamS3
  accessKeyId     : process.env.S3_KEY || 'bs',
  secretAccessKey : process.env.S3_SECRET || 'bs',
  awsAccountId    : process.env.AWS_ACCOUNT_ID || 'bs',
  region          : amazon.US_EAST_1,
  bucketName      : 'tiltnyc',
  concurrency     : 2

exports.getImageURIs = (req) ->
  base = "https://s3.amazonaws.com/tiltnyc/"
  (base + value.s3ObjectName for key, value of req.files when value.size)
