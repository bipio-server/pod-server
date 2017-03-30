/**
 *
 * Copyright (c) 2017 InterDigital, Inc. All Rights Reserved
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

var gulp = require('gulp'),
	fs = require("fs"),
	nodemon = require('gulp-nodemon'),
	coffee = require('gulp-coffee');

gulp.task('nodemon', function() {
	nodemon({ script: 'index.js', ext: 'coffee jade', ignore: ['pods/', 'src/client/']});
})

gulp.task('coffee', function() {
	gulp.src('./src/client/**/*.coffee').pipe(coffee({bare: true})).pipe(gulp.dest('./public/scripts/'));
});

gulp.task('watch', function () {
	gulp.watch("./src/client/**/*.coffee", ['coffee']);
});

gulp.task('default', ['nodemon', 'watch'])
