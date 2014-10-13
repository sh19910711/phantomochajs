through = require "through2"
path    = require "path"

scripts = {}

init_options = require "./init_options"
run_phantomjs = require "./run_phantomjs"
create_web_server = require "./create_web_server"

phantomochajs = (options)->
  options = init_options(options)

  webserver = create_web_server(scripts, options)

  # set up for test scripts
  stream = through.obj (file, enc, cb)->
    # add given test script
    relative_path = path.relative process.cwd(), file.path
    script_path = relative_path.slice(0, -1 * path.extname(file.path).length)
    scripts[script_path] = true
    cb()

  stream.on "end", ->
    unless options.server
      run_phantomjs(options)
        .on "exit", ->
          webserver.close()

  stream.on "kill", ->
    webserver.close()

  return stream

module.exports = phantomochajs

