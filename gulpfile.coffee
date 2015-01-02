gulp = require 'gulp'
browserify = require 'browserify'
transform = require 'vinyl-transform'
sourcemaps = require 'gulp-sourcemaps'
uglify = require 'gulp-uglify'
concat = require 'gulp-concat'
less = require 'gulp-less'
autoprefix = new (require 'less-plugin-autoprefix')
cleancss = new (require 'less-plugin-clean-css')
browserSync = require 'browser-sync'

paths =
  html: 'app/html/**/*.html'
  coffee: 'src/coffee/**/*.coffee'
  less: 'src/less/**/*.less'
  css: 'app/css'

gulp.task 'coffee', ->
  bundle = transform (files) ->
    browserify(
      entries: files
      extensions: ['.coffee']
      debug: true
    ).bundle()

  gulp.src('src/coffee/app.coffee')
    .pipe(bundle)
    .pipe(sourcemaps.init loadMaps: true)
      .pipe(uglify())
      .pipe(concat 'app.min.js')
    .pipe(sourcemaps.write '.')
    .pipe(gulp.dest 'app/js')

gulp.task 'less', ->
  gulp.src(paths.less)
    .pipe(sourcemaps.init())
      .pipe(less plugins: [autoprefix, cleancss])
      .pipe(concat 'style.min.css')
    .pipe(sourcemaps.write())
    .pipe(gulp.dest paths.css)

gulp.task 'server', ['coffee', 'less'], ->
  browserSync server:
    baseDir: 'app'
    index: 'html/index.html'

gulp.task 'reload', ->
  browserSync.reload()

gulp.task 'reload-coffee', ['coffee'], ->
  browserSync.reload()

gulp.task 'reload-less', ['less'], ->
  browserSync.reload()

gulp.task 'watch', ->
  gulp.watch paths.html, ['reload']
  gulp.watch paths.coffee, ['reload-coffee']
  gulp.watch paths.less, ['reload-less']

gulp.task 'default', ['watch', 'server']
