Fs = require 'fs'
Path = require 'path'

module.exports = (server) ->
  run = () ->
    metricPrefix = "load_average"
    server.cli.debug "Running load average script"

    # Read from /proc
    procfile = '/proc/loadavg'
    if Path.existsSync procfile
      data = Fs.readFileSync(procfile, 'utf-8')
      [one, five, fifteen] = data.split(' ', 3)
      obj = {}
      obj.short = parseFloat(one);
      obj.medium = parseFloat(five);
      obj.long = parseFloat(fifteen);
      server.push_metric "#{metricPrefix}", obj