# phantomochajs

Auto generate `test_runner.html` for client-side tests (mocha + phantomjs)

## Installation

```sh
$ npm install --save-dev phantomochajs
```

## Usage (with gulp)

```coffeescript
gulp = require "gulp"
phantomochajs = require "phantomochajs"

gulp.task "example/test", ->
  gulp.src ["spec/spec_helper.coffee", "spec/**/*_spec.coffee"]
    .pipe phantomochajs(
      host: "127.0.0.1"
      port: "28080"
    )
```

```sh
$ gulp example/test
```

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

