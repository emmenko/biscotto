fs      = require 'fs'
{inspect} = require 'util'
walkdir = require 'walkdir'
Biscotto = require '../src/biscotto'
Parser  = require '../src/parser'
Metadata = require '../src/metadata'

{diff}    = require 'jsondiffpatch'
_         = require 'underscore'
_.str     = require 'underscore.string'

require 'jasmine-focused'

describe "Metadata", ->
  parser = null

  constructDelta = (filename, hasReferences = false) ->
    source = fs.readFileSync filename, 'utf8'

    Biscotto.slugs = {}
    parser.parseContent source, filename
    metadata = new Metadata(filename, parser.classes, parser.files)
    metadata.generate(CoffeeScript.nodes(source))
    generated = Biscotto.populateSlug(filename, metadata)

    expected_filename = filename.replace(/\.coffee$/, '.json')
    expected = JSON.stringify(JSON.parse(fs.readFileSync expected_filename, 'utf8'), null, 2)
    generated =  JSON.stringify(generated, null, 2)

    diff(expected, generated)
    checkDelta(expected_filename, expected, generated, diff(expected, generated))

  checkDelta = (expected_filename, expected, generated, delta) ->
    if delta?
      if process.env.BISCOTTO_DEBUG
        fs.writeFileSync(expected_filename, generated + "\n")
      else
        console.error expected, generated
        console.error(delta)
        expect(delta).toBe(undefined)

  beforeEach ->
    parser = new Parser({
      inputs: []
      output: ''
      extras: []
      readme: ''
      title: ''
      quiet: false
      private: true
      verbose: true
      metadata: true
      github: ''
    })

  describe "Classes", ->
    it 'understands descriptions', ->
      constructDelta("spec/metadata_templates/classes/basic_class.coffee")

    it 'understands class properties', ->
      constructDelta("spec/metadata_templates/classes/class_with_class_properties.coffee")

    it 'understands prototype properties', ->
      constructDelta("spec/metadata_templates/classes/class_with_prototype_properties.coffee")

  describe "Exports", ->
    it 'understands basic exports', ->
      constructDelta("spec/metadata_templates/exports/basic_exports.coffee")

    it 'understands class exports', ->
      constructDelta("spec/metadata_templates/exports/class_exports.coffee")

  describe "Requires", ->
    it 'understands basic requires', ->
      constructDelta("spec/metadata_templates/requires/basic_requires.coffee")

    it 'understands importing', ->
      constructDelta("spec/metadata_templates/requires/references/buffer-patch.coffee")