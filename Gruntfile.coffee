module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    sass:
      dist:
        options:
          sourcemap: 'none'
          style: 'expanded'
        files: [
          cwd: 'src',
          src: ['**/*.scss'],
          dest: '../build',
          ext: '.css',
        ]
    meta:
      banner: """
        /**
        * <%= pkg.name %>
        * <%= pkg.description %>\n
        * @author <%= pkg.author.name %> <<%= pkg.author.email %>>
        * @copyright <%= pkg.author.name %> <%= grunt.template.today('yyyy') %>
        * @license <%= pkg.licenses[0].type %> <<%= pkg.licenses[0].url %>>
        * @link <%= pkg.homepage %>
        * @module <%= pkg.module %>
        * @version <%= pkg.version %>
        */\n
      """
    coffeelint:
      src: 'src/**/*.coffee'
      options:
        max_line_length:
          level: 'ignore'
    clean:
      dist:
        build: ["compile/**", "build/**"]
      test:
        build: ["compile/**"]
    coffee:
      compile:
        files: [
          expand: true
          cwd: 'src/'
          src: '**/*.coffee'
          dest: 'compile/'
          ext: '.js'
        ],
        options:
          bare: true
      test:
        files: [
          expand: true,
          cwd: 'spec',
          src: '**/*.coffee',
          dest: 'compile/spec',
          ext: '.js'
        ]
    concat:
      options:
        banner: '<%= meta.banner %>'
      dist:
        src: 'compile/please-wait.js'
        dest: 'build/please-wait.js'
    uglify:
      options:
        banner: '<%= meta.banner %>'
      dist:
        src: ['build/please-wait.js']
        dest: 'build/please-wait.min.js'
    cssmin:
      options:
        sourceMap: false
      target:
        files: [
          expand: true,
          cwd: 'build',
          src: ['*.css', '!*.min.css'],
          dest: 'build',
          ext: '.min.css'
        ]
    jasmine:
      please_wait:
        src: 'compile/**/*.js'
        options:
          specs: 'compile/spec/*.spec.js',
          helpers: 'compile/spec/*.helper.js'

  grunt.registerTask 'default', ['coffeelint', 'clean', 'sass', 'coffee', 'concat', 'uglify', 'cssmin']
  grunt.registerTask 'test', [
    'coffeelint',
    'clean:test',
    'coffee',
    'jasmine'
  ]
