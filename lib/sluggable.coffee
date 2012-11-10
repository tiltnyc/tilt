slug = require 'slug'

module.exports =
  sluggable: (schema, field) ->

    schema.add({ _slug: { type: String } })

    schema.pre 'save', (next) ->
      this._slug = slug this[field].toLowerCase()
      next()

    schema

  findable: ( model ) ->
    model.__findById = model.findById
    model.findById = (idOrSlug, next) ->
      model.findOne { slug: idOrSlug }, (error, doc) ->
        if doc
          next(error, doc)
        else
          model.__findById idOrSlug, next

    model
