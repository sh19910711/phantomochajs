# phantomochajs

[![Build Status](https://travis-ci.org/sh19910711/phantomochajs.svg?branch=master)](https://travis-ci.org/sh19910711/phantomochajs)

Auto generate `test_runner.html` for client-side tests (mocha + phantomjs)

## Installation

```sh
$ npm install --save-dev phantomochajs
```

## Usage (with gulp)

If you want to see examples, here is the link below:

* phantomochajs (mocha + phantomjs) + requirejs + backbone
  * https://github.com/sh19910711/phantomochajs-example

### Example: gulpfile.coffee

```coffeescript
gulp = require "gulp"
phantomochajs = require "phantomochajs"

gulp.task "example/test", ->
  # specify test scripts in src
  gulp.src ["spec/spec_helper.coffee", "spec/**/*_spec.coffee", "spec/**/*_spec.js"]
    .pipe phantomochajs(
      host: "127.0.0.1"
      port: "28080"
    )
```

### Run gulp

```sh
$ gulp example/test
```

### Result

```text
[21:00:00] Requiring external module coffee-script/register
[21:00:01] Using gulpfile ~/workspace/phantomochajs/gulpfile.coffee
[21:00:01] Starting 'example'...
[21:00:02] Finished 'example' after 573 ms


  this is coffeescript
    ✓ hello 

  this is javascript
    ✓ hello 


  2 passing (5ms)

```

## Options

Key | Type | Default | Description |
--- | --- | --- | --- |
`host` | `String` | `127.0.0.1` | hostname of the webserver
`port` | `Number` | `28080` | port of the webserver
`server` | `Boolean` | `false` | keep the webserver
`dependencies` | `Array` | requirejs | depend modules
`test_dependencies` | `Array` | mocha, chai, sinon | depended modules on test
`reporter` | `String` | `spec` | mocha reporter

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

MIT

## Links

* https://github.com/mrhooray/gulp-mocha-phantomjs
* https://github.com/schickling/gulp-webserver

