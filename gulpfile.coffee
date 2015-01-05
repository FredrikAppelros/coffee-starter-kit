fs = require 'fs'
path = require 'path'
Q = require 'q'
gulp = require 'gulp'
browserify = require 'browserify'
transform = require 'vinyl-transform'
sourcemaps = require 'gulp-sourcemaps'
uglify = require 'gulp-uglify'
rename = require 'gulp-rename'
less = require 'gulp-less'
autoprefix = new (require 'less-plugin-autoprefix')
cleancss = new (require 'less-plugin-clean-css')
browserSync = require 'browser-sync'

argv = require('yargs')
  .requiresArg('e')
  .alias('e', 'export')
  .describe('e', 'Exports the kit to the specified directory')
  .argv

paths =
  html: 'app/html/**/*.html'
  coffee: 'src/coffee/**/*.coffee'
  less: 'src/less/**/*.less'
  css: 'app/css'
  entry: [
    'src/coffee/app.coffee'
  ]
  export: [
    'app/html/index.html'
    'src/coffee/app.coffee'
    'src/coffee/foo.coffee'
    'src/less/style.less'
    '.gitignore'
    'bower.json'
    'gulpfile.coffee'
    'package.json'
    'README.md'
  ]

compileCoffee = ->
  bundle = transform (files) ->
    browserify(
      entries: files
      extensions: ['.coffee']
      debug: true
    ).bundle()

  Q.Promise (resolve) ->
    gulp.src(paths.entry)
      .pipe(bundle)
      .pipe(sourcemaps.init loadMaps: true)
        .pipe(uglify())
        .pipe(rename extname: '.min.js')
      .pipe(sourcemaps.write '.')
      .pipe(gulp.dest 'app/js')
      .on('end', resolve)

compileLess = ->
  Q.Promise (resolve) ->
    gulp.src(paths.less)
      .pipe(sourcemaps.init())
        .pipe(less plugins: [autoprefix, cleancss])
        .pipe(rename extname: '.min.css')
      .pipe(sourcemaps.write())
      .pipe(gulp.dest paths.css)
      .on('end', resolve)

startServer = ->
  Q.all([
    compileCoffee()
    compileLess()
  ]).then ->
    browserSync server:
      baseDir: 'app'
      index: 'html/index.html'

watchFiles = ->
  gulp.watch paths.html, ['reload-html']
  gulp.watch paths.coffee, ['reload-coffee']
  gulp.watch paths.less, ['reload-less']

gulp.task 'reload-html', ->
  browserSync.reload()

gulp.task 'reload-coffee', ->
  compileCoffee().then ->
    browserSync.reload()

gulp.task 'reload-less', ->
  compileLess().then ->
    browserSync.reload()

gulp.task 'default', ->
  if argv.export
    gulp.src(paths.export, base: '.')
      .pipe(gulp.dest argv.export)
      .on('end', ->
        fs.symlink path.join(argv.export, 'bower_components'),
                   path.join(argv.export, 'app/lib')
      )
  else
    startServer().then ->
      watchFiles()
