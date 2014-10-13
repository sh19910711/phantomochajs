path  = require "path"
fs    = require "fs"
spawn = require("child_process").spawn

# run phantomjs after set up
# ref: https://github.com/mrhooray/gulp-mocha-phantomjs/blob/fc52722bfd59000a909b1499b26ff2f14b9e18c2/index.js#L52
run_phantomjs = (options)->
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

# ref: https://github.com/mrhooray/gulp-mocha-phantomjs/blob/fc52722bfd59000a909b1499b26ff2f14b9e18c2/index.js#L82
lookup = (target_path, is_executable)->
  module.paths
    .map (module_path)->
      abs_path = path.join(module_path, target_path)
      if is_executable && process.platform == 'win32'
        abs_path += '.cmd'
      return abs_path
    .filter (abs_module_path)->
      if fs.existsSync(abs_module_path)
        return true
    .shift()


module.exports = run_phantomjs
