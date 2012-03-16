module.exports = function(server) {
  var run;

  run = function() {
    var metricPrefix, uptime;
    metricPrefix = "node";
    server.cli.debug("Running node script");

    // Node os object makes this easy
    mem = process.memoryUsage();
    server.push_metric(metricPrefix, mem);
  }
  return run;
}
