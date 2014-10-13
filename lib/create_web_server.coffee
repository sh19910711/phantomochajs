connect         = require "connect"
connect_mincer  = require "connect-mincer"

http  = require "http"
jade  = require "jade"
fs    = require "fs"
path  = require "path"

create_web_server = (scripts, options)->

  app = connect()

  # GET /test_runner.html
  app.use (req, res, next)->
    if /^\/test_runner.html\??/.test(req.url)
      # render test runner for mocha
      res.end(
        jade.compile(
          fs.readFileSync(path.join(__dirname, "test_runner.jade"))
        )(
          scripts: Object.keys(scripts)
          dependencies: options.dependencies
          test_dependencies: options.test_dependencies
          mocha_css_url: options.mocha_css_url
          js: (path)-> "<script src=\"#{path}.js\"></script>"
        )
      )
    else
      next()

  mincer_engine = new connect_mincer(
    root: process.cwd()
    paths: ["./"]
    mount_point: "/"
    production: false
  )
  app.use mincer_engine.createServer()

  # create http server
  webserver = http.createServer(app).listen(parseInt(options.port, 10), options.host)

module.exports = create_web_server
