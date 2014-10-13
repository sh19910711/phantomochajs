connect         = require "connect"
connect_mincer  = require "connect-mincer"
path  = require "path"
glob  = require "glob"
fs    = require "fs"
jade  = require "jade"

is_test_runner = (url)->
  return true if /^\/test_runner.html$/.test(url)
  return true if /^\/test_runner.html\?/.test(url)
  return false

has_glob = (url)->
  return /\*/.test(url)

check_glob = (glob_url, url)->
  glob_url = glob_url.replace /\*/, '.*'
  regexp = new RegExp(glob_url)
  return regexp.test(url)

to_class_name = (script_path)->
  name = path.basename(script_path)
  name = name.replace(/\..*$/, '')
  # snake to camel
  name = name.charAt(0).toUpperCase() + name.slice(1)
  name = name.replace /(_[a-z])/g, (t)-> t.replace(/^_/, '').toUpperCase()
  return name

# create app
create_app = (scripts, options)->

  app = connect()

  # GET /test_runner.html
  app.use (req, res, next)->
    if is_test_runner(req.url)
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
    if options.debug
      app.use (req, res, next)->
        if req.url == "/debug"
          res.setHeader 'Content-Type', 'text/html'
          res.end [
            '<script src="//cdnjs.cloudflare.com/ajax/libs/require.js/2.1.15/require.min.js"></script>'
            '<script src="/modules/*.js"></script>'
          ].join("")
        else
          next()

    app.use (req, res, next)->
      if has_glob(req.url)
        glob_path = req.url.slice(1).replace(/\..*/, '')
        glob_path = path.relative(process.cwd(), glob_path)
        module_paths = glob.sync(glob_path)

        paths = module_paths
          .filter (script_path)->
            check_glob(glob_path, script_path)
          .map (script_path)->
            '"' + script_path.replace(/\..*$/, '') + '"'

        class_names = module_paths
          .filter (script_path)->
            check_glob(glob_path, script_path)
          .map (script_path)->
            to_class_name(script_path)

        pairs = class_names.map (name)->
          "#{name}: #{name}"

        res_html = [
          "(function() {define(["
          paths.join(", ")
          "], function("
          class_names.join(", ")
          ") {"
          "return {"
          pairs.join(", ")
          "};"
          "});})();"
        ].join("")
        res.setHeader('Content-Type', 'application/javascript');
        res.end res_html
      else
        next()

  mincer_engine = new connect_mincer(
    root: process.cwd()
    paths: ["./"]
    mount_point: "/"
    production: false
  )
  app.use mincer_engine.createServer()

module.exports = create_app
