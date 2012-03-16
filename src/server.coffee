EventEmitter = require('events').EventEmitter
Path         = require 'path'
Util         = require 'util'
Fs           = require 'fs'

class HoardD extends EventEmitter
  
  constructor: (@conf, @cli) ->
    @sPath = @conf.scriptPath
    @fqdn = @conf.fqdn.split('.').join('_')
    @util = Util

    # Containers
    @scripts  = []
    @pending  = {}
    super

  load_scripts: ->
    for file in Fs.readdirSync @sPath
      ext = Path.extname file
      continue unless ext in [ '.coffee', '.js' ]
      toLoad = Path.join(@sPath, Path.basename file)
      try
        @cli.info "Loading script #{toLoad}"
        @scripts.push(require(toLoad) @)
      catch error
        @cli.fatal "Failed to load #{toLoad}: #{error}"
        process.exit()

  now: ->
    date  = new Date()
    now   = Math.round date.getTime()/1000

  push_metric: (prefix, value) ->
    try
      @pending[prefix] = value
      @cli.debug "#{prefix} #{value} #{@now()}"
    catch error
      @cli.fatal "Error adding metric: #{error}"
  
  run_scripts: ->
    for script in @scripts
      try
        script()
      catch error
        @cli.fatal "Error while running #{script.name}: #{error}"

    
module.exports = HoardD