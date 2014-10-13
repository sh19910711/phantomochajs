gulp = require "gulp"
phantomochajs = require "./lib"

gulp.task "example", ->
  test_scripts = [
    "spec/spec_helper.coffee"
    "spec/**/*_spec.coffee"
    "spec/**/*_spec.js"
  ]
  gulp.src test_scripts
    .pipe phantomochajs()

gulp.task "default", ["example"]

# * * *

gulp.task "test/check/watch", ->
  gulp.watch(
    [
      "spec/**/*.coffee"
    ]
    [
      "example"
    ]
  )

