gulp = require "gulp"
phantomochajs = require "../lib/index"

gulp.task "example/fail", ->
  gulp.src ["test/fixtures/failed_test.coffee"]
    .pipe phantomochajs()

gulp.task "example/pass", ->
  gulp.src ["test/fixtures/passed_test.coffee"]
    .pipe phantomochajs()

