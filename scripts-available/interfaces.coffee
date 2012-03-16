Fs = require 'fs'

module.exports = (server) ->
  run = () ->
    metricPrefix = "interfaces"
    server.cli.debug "Running the interfaces scripts"
    nameArray = [
      'rxBytes', 'rxPackets', 'rxErrors', 'rxDrops', 
      'rxFifo', 'rxFrame', 'rxCompressed', 'rxMulticast',
      'txBytes', 'txPackets', 'txErrors', 'txDrops', 
      'txFifo', 'txColls', 'txCarrier', 'txCompressed'
    ]

    # Reads from proc
    procfile = '/proc/net/dev'
    content = Fs.readFileSync(procfile, 'ascii').trim()
    interfaceObj = {}
    for line in content.split('\n')[2...]
      continue if line.match /lo:/ 
      regex = /(.+):(.*)/
      matched = line.match(regex)
      interface = matched[1].trim()
      values = matched[2].trim().split /\s+/
      
      statObj = {}
      statObj[key] = values[i] for key, i in nameArray
      interfaceObj[interface] = statObj
    
    server.push_metric "#{metricPrefix}", interfaceObj 
