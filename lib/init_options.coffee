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

  options.amd_glob ||= false

  # mocha config
  options.reporter ||= 'spec'
  options.mocha_css_url ||= "//cdnjs.cloudflare.com/ajax/libs/mocha/1.21.4/mocha.css"

  # to debug
  options.debug ||= true

  return options

module.exports = init_options
