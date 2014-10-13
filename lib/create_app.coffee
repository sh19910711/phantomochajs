connect         = require "connect"
connect_mincer  = require "connect-mincer"
path  = require "path"
fs    = require "fs"
jade  = require "jade"

# create app
create_app = (scripts, options)->

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

  if options.amd_glob
    app.use (req, res, next)->
      next()

  mincer_engine = new connect_mincer(
    root: process.cwd()
    paths: ["./"]
    mount_point: "/"
    production: false
  )
  app.use mincer_engine.createServer()

module.exports = create_app
