gulp = require 'gulp'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
clean = require 'gulp-clean'
jade = require 'gulp-jade'
stylus = require 'gulp-stylus'
browserify = require 'browserify'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
minifyCss = require 'gulp-minify-css'
source = require 'vinyl-source-stream'
watchify = require 'watchify'
streamify = require 'gulp-streamify'
preprocess = require 'gulp-preprocess'
nib = require 'nib'
browserSync = require 'browser-sync'
modRewrite = require 'connect-modrewrite'
rsync = require('rsyncwrapper').rsync
pkg = require './package.json'
cfg = require './config.json'

logError = (msg) ->
  gutil.log gutil.colors.red(msg)
  process.exit(1)

if process.env.NODE_ENV? and (process.env.NODE_ENV isnt 'dev' and process.env.NODE_ENV isnt 'prod')
  logError 'NODE_ENV should be "dev" or "prod".'

devDir = './compiled'
prodDir = './dist'

baseDir = if process.env.NODE_ENV is 'prod' then prodDir else devDir
env = if process.env.NODE_ENV is 'prod' then 'production' else 'development'

context =
  VERSION: pkg.version
  ENV: env
  BASEDIR: baseDir

stylusPaths = [
  './src/stylus/**/*.styl'
]
gulp.task 'server', ->
  browserSync.init null,
    server:
      baseDir: context.BASEDIR
      middleware: [
        modRewrite([
          '^[^\\.]*$ /index.html [L]'
        ])
      ]

gulp.task 'stylus', ->
  gulp.src(stylusPaths)
    .pipe(stylus(
      use: [nib()]
    ))
    .pipe(concat("main-#{context.VERSION}.css"))
    .pipe(gulp.dest("#{context.BASEDIR}/css"))
    .pipe(browserSync.reload(stream: true))

gulp.task 'uglify', ->
  gulp.src("#{devDir}/js/*")
    .pipe(concat("main-#{context.VERSION}.js", newLine: '\r\n;'))
    .pipe(uglify())
    .pipe(gulp.dest(prodDir+'/js/'))

gulp.task 'minify-css', ->
  gulp.src("#{devDir}/css/main-#{context.VERSION}.css")
    .pipe(minifyCss())
    .pipe(gulp.dest(prodDir+'/css'))

gulp.task 'clean', -> gulp.src(context.BASEDIR+'/*').pipe(clean())

gulp.task 'copy-static', -> gulp.src('./static/**/*').pipe(gulp.dest(context.BASEDIR))

gulp.task 'copy-hilib-images', ['copy-static'], -> gulp.src('./node_modules/hilib/images/**/*').pipe(gulp.dest(context.BASEDIR+'/images/hilib'))

gulp.task 'compile', ['clean'], ->
  if context.ENV is 'production'
    gulp.start 'build', ->
      logError "Error: The compile task has not run! Compile the project only with NODE_ENV=dev! (#{context.BASEDIR} is re-build!)"
  else
    gulp.start 'copy-hilib-images', 'browserify', 'browserify-libs', 'jade', 'stylus'

gulp.task 'build', ['clean'], ->
  if context.ENV is 'development'
    gulp.start 'compile', ->
      logError "Error: The build task has not run! Build project only with NODE_ENV=prod! (#{context.BASEDIR} is re-compiled!)"
  else
    gulp.start 'jade', 'copy-hilib-images', 'uglify', 'minify-css'


gulp.task 'jade', ->
  gulp.src('./src/index.jade')
    .pipe(jade())
    .pipe(preprocess(context: context))
    .pipe(gulp.dest(context.BASEDIR))
    .pipe(browserSync.reload(stream: true))

gulp.task 'watch', ->
  logError 'Watch files only in "development".' if context.ENV is 'production'
  gulp.watch ['./src/index.jade'], ['jade']
  gulp.watch [stylusPaths], ['stylus']

createBundle = (watch=false) ->
  args =
    entries: './src/coffee/index.cjsx'
    extensions: ['.cjsx', '.coffee']

  bundler = if watch then watchify(args) else browserify(args)

#  bundler.transform('coffeeify')
  bundler.transform('coffee-reactify')
  bundler.transform('envify')

  bundler.exclude 'underscore'
  bundler.exclude 'react'

  rebundle = ->
    gutil.log('Watchify rebundling') if watch
    bundler.bundle()
      .pipe(source("src-#{context.VERSION}.js"))
      .pipe(gulp.dest("#{context.BASEDIR}/js"))
      .pipe(browserSync.reload({stream:true, once: true}))

  bundler.on('update', rebundle)

  rebundle()

gulp.task 'browserify', -> createBundle false
gulp.task 'watchify', -> createBundle true

gulp.task 'browserify-libs', ->
  libs =
    underscore: './node_modules/underscore/underscore'
    react: './node_modules/react/react'

  paths = Object.keys(libs).map (key) -> libs[key]

  bundler = browserify paths

  for own id, path of libs
    bundler.require path, expose: id

  gutil.log('Browserify: bundling libs')
  bundler.bundle()
    .pipe(source("libs-#{pkg.version}.js"))
    .pipe(gulp.dest("#{context.BASEDIR}/js"))

gulp.task 'deploy', (done) ->
  rsync
    src: 'dist/', # Keep the slash at the end!
    dest: cfg['remote'],
    recursive: true
  ,
    (error, stdout, stderr, cmd) ->
      console.log cmd
      if error
        new gutil.PluginError('test', 'something broke', showStack: true)
      else
        done()

gulp.task 'default', ['server', 'watch', 'watchify']