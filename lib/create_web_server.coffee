create_app = require "./create_app"
http  = require "http"

# create web server
create_web_server = (scripts, options)->

  app = create_app(scripts, options)

  # create http server
  webserver = http.createServer(app).listen(parseInt(options.port, 10), options.host)

module.exports = create_web_server
