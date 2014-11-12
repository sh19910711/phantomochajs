gulp = require "gulp"
mocha = require "gulp-mocha"

require "./example_tasks/exit_status.coffee"

gulp.task "test", ->
  gulp.src ["spec/**/*_spec.coffee"]
    .pipe mocha()

gulp.task "watch", ->
  gulp.watch(
    [
      "spec/**/*.coffee"
      "lib/**"
    ]
    [
      "test"
    ]
  )

gulp.task "default", ["test"]

