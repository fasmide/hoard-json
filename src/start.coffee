Server = require './server'
Path   = require 'path'
Cli    = require('cli').enable('status', 'version')
Fs     = require 'fs'
http   = require "http"

# Command Line Setup
module.exports = entry_point = () ->
  Cli.enable 'version'
  Cli.setUsage 'node start.js -c <config json>'
  Cli.setApp 'HoardDaemon', '0.1.0'
  Cli.parse
    'config': ['c', 'Configuration file path', 'path', './config.json']

  Cli.main (args, options) ->
    if Path.existsSync options.config
      try
        conf = JSON.parse(Fs.readFileSync(options.config, 'utf-8'))
      catch error
        cli.debug "Error parsing config file: #{error}"
    else
      Cli.fatal "Can't find a config file"

    hoard = new Server conf, Cli
    hoard.load_scripts()

    hoard.on 'run', hoard.run_scripts

    setInterval(->
      hoard.emit 'run'
    ,conf.sampleInterval * 1000)

    Cli.info "HoardD started. Samples each #{conf.sampleInterval} seconds."
    web = http.createServer (req, res) ->
      res.writeHead 200, {"Content-Type": "application/json", "Access-Control-Allow-Origin": "*"}
      res.end JSON.stringify hoard.pending
    web.listen conf.webPort
    Cli.info "Web server started port 8000"
