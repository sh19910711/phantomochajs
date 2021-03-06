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

convert_snake_to_camel = (name)->
  name = name.charAt(0).toUpperCase() + name.slice(1)
  name = name.replace /(_[a-z])/g, (t)-> t.replace(/^_/, '').toUpperCase()
  return name
 

to_class_name = (script_path)->
  name = path.basename(script_path)
  name = name.replace(/\..*$/, '')
  # snake to camel
  name = convert_snake_to_camel(name)
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
            '<script src="/spec/*.js"></script>'
          ].join("")
        else
          next()

    app.use (req, res, next)->
      if has_glob(req.url)
        glob_path = req.url.slice(1).replace(/\..*/, '')
        glob_path = path.relative(process.cwd(), glob_path)
        module_paths = glob.sync(glob_path)

        parent_path = glob_path.replace(/\/\*$/, '')
        unless fs.existsSync(parent_path) && fs.lstatSync(parent_path).isDirectory()
          res.statusCode = 404
          res.end "404"
          return

        parent_name = convert_snake_to_camel(path.basename(glob_path.replace(/\/\*$/, '')))

        paths = module_paths
          .filter (script_path)->
            check_glob(glob_path, script_path)
          .map (script_path)->
            if fs.lstatSync(script_path).isDirectory()
              '"/' + script_path.replace(/\..*$/, '') + '/*"'
            else if fs.lstatSync(script_path).isFile()
              '"/' + script_path.replace(/\..*$/, '') + '"'
            else
              throw new Error

        class_names = module_paths
          .filter (script_path)->
            check_glob(glob_path, script_path)
          .map (script_path)->
            to_class_name(script_path)

        pairs = class_names.map (name)->
          "#{parent_name}.prototype.#{name} = #{name};"

        res_html = [
          "(function() {define(["
          paths.join(", ")
          "], function("
          class_names.join(", ")
          ") {"
          "function #{parent_name}() {};"
          pairs.join("")
          "return #{parent_name};"
          "});})();"
        ].join("")

        res.setHeader "Content-Type", "application/javascript"
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
