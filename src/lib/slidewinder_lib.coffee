# Slidewinder-Lib.
fs = require 'fs'
path = require 'path'
fm = require 'front-matter'
handlebars = require 'handlebars'
_ = require 'lodash'
mkdirp = require 'mkdirp'
yaml = require 'js-yaml'
logger = require './log.js'

log_colours =
  silly: 'magenta'
  input: 'grey'
  verbose: 'cyan'
  prompt: 'grey'
  debug: 'blue'
  info: 'green'
  data: 'grey'
  help: 'cyan'
  warn: 'yellow'
  error: 'red'

# Load a Markdown format slide collection
loadCollection = (dirpath) ->
  collection = {}
  # Load each slide, parse the frontmatter, and collect.
  fs.readdirSync(dirpath).forEach (file) ->
      filepath = path.resolve(dirpath, file)
      data = fs.readFileSync(filepath, 'utf8')
      slide = fm data
      name = slide.attributes.name
      if collection[name]
          log.error('Multiple slides have the name', name)
      else
          collection[name] = slide
      slidenum = Object.keys(collection).length
  log.info('Loaded', slidenum, 'markdown slide files from', dirpath)
  collection

pickSlides = (collection, selections) ->
  picked = []
  selections.forEach (selection) ->
      slide = collection[selection]
      if slide
          picked.push slide
      else
          log.error('No slide found with name', name)
  log.info('Picked', picked.length, 'slides from collection')
  picked

class PresentationFramework
  constructor: (framework) ->
    log.info('Looking for presentation framework module: ', framework)
    frameworkPath = path.join(framework, 'template.html')
    @template = fs.readFileSync(frameworkPath, 'utf8')
    @renderer = handlebars.compile @template
    @helpers = require path.join(framework, 'helpers.js')

    @renderDeck = (data) =>
      Object.keys(@helpers).forEach (key) =>
          handlebars.registerHelper(key, @helpers[key])
          deck = @renderer(data)
          deck
    this

# Save a rendered slide deck
saveDeck = (deck, data) ->
    mkdirp data.output
    # Write deck
    deckPath = path.resolve(data.output, 'index.html')
    fs.writeFileSync(deckPath, deck)
    # Write slidewinder data
    dataPath = path.resolve(data.output, 'deck.json')
    dataOutput = JSON.stringify(data, null, 2)
    fs.writeFileSync(dataPath, dataOutput)
    msg = 'Deck (index.html) and Data (deck.json) saved to '
    log.info(msg, data.output)

# Function executes the main slidewinder flow.
slidewinder = (sessiondata) ->
    # Load the slides, and select the ones desired.
    allslides = loadCollection sessiondata.collection
    sessiondata.slideset = pickSlides(allslides, sessiondata.slides)
    # Load the Plugin for the framework that will be used.
    plugin = new PresentationFramework sessiondata.framework
    # Render and save
    deck = plugin.renderDeck sessiondata
    saveDeck(deck, sessiondata)

log = logger()

module.exports = slidewinder
