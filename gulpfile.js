var gulp       = require('gulp');
var concat     = require('gulp-concat');
var uglify     = require('gulp-uglify');
var imagemin   = require('gulp-imagemin');
var pngquant   = require('imagemin-pngquant');
var sourcemaps = require('gulp-sourcemaps');

var paths = {
  scripts: ['javascripts/libs/*.js',
            'javascripts/*.js',
            '!javascripts/pinboard.js',
            '!javascripts/twitter.js'],
  images: 'photos/**/*'
};

// Minify and concat javascript
gulp.task('minify-js', function () {
  return gulp.src(paths.scripts)
             .pipe(sourcemaps.init())
             .pipe(uglify())
             .pipe(concat('dist.min.js'))
             .pipe(sourcemaps.write())
             .pipe(gulp.dest('source/javascripts'));
});

// Optimize all static images
gulp.task('images', function () {
  return gulp.src(paths.images)
             .pipe(imagemin({
               optimizationLevel : 5,
               progressive       : true,
               svgoPlugins       : [{removeViewBox: false}],
               use: [pngquant({ quality: '65-80', speed: 4 })]
             }))
             .pipe(gulp.dest('source/photos'));
});

// Rerun the task when a file changes
gulp.task('watch', function () {
  gulp.watch(paths.scripts, ['minify-js']);
  gulp.watch(paths.images, ['images']);
});

gulp.task('default', ['minify-js']);
