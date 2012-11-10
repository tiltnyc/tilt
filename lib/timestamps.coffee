module.exports = ( schema ) ->

  schema.add
    created_at:
      type:    Date
      default: Date.now
    updated_at:
      type:    Date
      default: Date.now

  schema
