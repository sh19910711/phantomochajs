through = require "through2"
http    = require "http"
connect = require "connect"
connect_mincer = require "connect-mincer"
path    = require "path"
jade    = require "jade"
fs      = require "fs"
spawn   = require("child_process").spawn

scripts = []

# Set default options unless defined
init_options = (options)->
  options         ||= {}

  # test runner config
  options.host    ||= '127.0.0.1'
  options.port    ||= '28080'
  options.server  ||= false

  options.test_dependencies ||= [
    '//cdnjs.cloudflare.com/ajax/libs/chai/1.9.2/chai.js'
    '//cdnjs.cloudflare.com/ajax/libs/mocha/1.21.4/mocha.js'
    '//cdnjs.cloudflare.com/ajax/libs/sinon.js/1.7.3/sinon-min.js'
  ]

  options.dependencies ||= [
    '//cdnjs.cloudflare.com/ajax/libs/require.js/2.1.14/require.min.js'
  ]

  # mocha config
  options.reporter ||= 'spec'

  return options

run_phantomjs = (options)->
  # run phantomjs after set up
  # ref: https://github.com/mrhooray/gulp-mocha-phantomjs/blob/fc52722bfd59000a909b1499b26ff2f14b9e18c2/index.js#L52
  phantomjs_path = lookup('.bin/phantomjs', true) || lookup('phantomjs/bin/phantomjs', true)

  unless phantomjs_path
    return new Error('PhantomJS not found')

  script_path = lookup('mocha-phantomjs/lib/mocha-phantomjs.coffee')

  args = [
    script_path
    "http://#{options.host}:#{options.port}/test_runner.html"
    options.reporter
  ]

  phantomjs = spawn(phantomjs_path, args)
  phantomjs.stdout.pipe process.stdout
  phantomjs.stderr.pipe process.stderr

  return phantomjs

phantomochajs = (options)->
  options = init_options(options)

  app = connect()

  # GET /test_runner.html
  app.use (req, res, next)->
    if req.url == "/test_runner.html"
      # render test runner for mocha
      res.end(
        jade.compile(
          fs.readFileSync(path.join(__dirname, "test_runner.jade"))
        )(
          scripts: scripts
          dependencies: options.dependencies
          test_dependencies: options.test_dependencies
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

  # set up for test scripts
  stream = through.obj (file, enc, cb)->
    # add given test script
    relative_path = path.relative process.cwd(), file.path
    scripts.push relative_path.slice(0, -1 * path.extname(file.path).length)
    cb()

  stream.on "end", ->
    unless options.server
      run_phantomjs(options)
        .on "exit", ->
          webserver.close()

  stream.on "kill", ->
    webserver.close()

  return stream

# ref: https://github.com/mrhooray/gulp-mocha-phantomjs/blob/fc52722bfd59000a909b1499b26ff2f14b9e18c2/index.js#L82
lookup = (target_path, isExecutable)->
  module.paths
    .map (module_path)->
      abs_path = path.join(module_path, target_path)
      if isExecutable && process.platform == 'win32'
        abs_path += '.cmd'
      return abs_path
    .filter (abs_module_path)->
      if fs.existsSync(abs_module_path)
        return true
    .shift()

module.exports = phantomochajs

