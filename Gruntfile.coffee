"use strict"
lrSnippet = require("grunt-contrib-livereload/lib/utils").livereloadSnippet
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)

# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to match all subfolders:
# 'test/spec/**/*.js'
module.exports = (grunt) ->

  # load all grunt tasks
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks

  # configurable paths
  yeomanConfig =
    src: "source"
    release: "release"
  
  grunt.initConfig
    y: yeomanConfig
    watch:
      coffee:
        files: ["<%= y.src %>/scripts/{,*/}*.coffee"]
        tasks: ["coffee:deploy"]

      coffeeTest:
        files: ["test/spec/{,*/}*.coffee"]
        tasks: ["coffee:test"]

      jade:
        files: ["<%= y.src %>/*.jade"]
        tasks: ["jade:debug"]

      stylus:
        files: ["<%= y.src %>/*.styl"]
        tasks: ["styl:debug"]

      livereload:
        files: [".tmp/*.html", ".tmp/*.css", ".tmp/scripts/{,*/}*.js", "<%= y.src %>/images/{,*/}*.{png,svg,jpg,jpeg,webp}"]
        tasks: ["livereload"]

    connect:
      options:
        port: 9000
        # change this to '0.0.0.0' to access the server from outside
        hostname: "localhost"

      livereload:
        options:
          middleware: (connect) -> [
            lrSnippet, mountFolder(connect, ".tmp"), 
            mountFolder(connect, "source") 
          ]

            #test:
            #options:
            #middleware: (connect) ->
            #[mountFolder(connect, ".tmp"), mountFolder(connect, "test")]

            #deploy:
            #options:
            #middleware: (connect) ->
            #[mountFolder(connect, "deploy")]

    open:
      server:
        path: "http://localhost:<%= connect.options.port %>"

    clean:
      release: [".tmp", "<%= y.release %>/*"]
      debug: ".tmp"

    jshint:
      options:
        jshintrc: ".jshintrc"

      all: ["Gruntfile.js", "<%= y.src %>/scripts/{,*/}*.js", "!<%= y.src %>/scripts/vendor/*", "test/spec/{,*/}*.js"]

    coffee:
      deploy:
        files: [

          # rather than compiling multiple files here you should
          # require them into your main .coffee file
          expand: true
          cwd: "<%= y.src %>/scripts"
          src: "*.coffee"
          dest: ".tmp/scripts"
          ext: ".js"
        ]

      test:
        files: [
          expand: true
          cwd: ".tmp/spec"
          src: "*.coffee"
          dest: "test/spec"
        ]

    jade:
      release:
        files: grunt.file.expandMapping(["*.jade"], "release/",
          cwd: "source"
          rename: (base, path) ->
            base + path.replace(/\.jade$/, ".html")
        )
        options:
          client: false
          pretty: false
          data:
            title: "hello from gruntfile"

      debug:
        files: grunt.file.expandMapping(["*.jade"], ".tmp/",
          cwd: "source"
          rename: (base, path) ->
            base + path.replace(/\.jade$/, ".html")
        )
        options:
          client: false
          pretty: true
          data:
            title: "hello from gruntfile"

    stylus:
      release:
        files: grunt.file.expandMapping(["*.styl"], "release/",
          cwd: "source"
          rename: (base, path) ->
            base + path.replace(/\.styl$/, ".css")
        )
        options:
          compress: false
          paths: ["node_modules/grunt-contrib-stylus/node_modules"]

      debug:
        files: grunt.file.expandMapping(["*.styl"], ".tmp/",
          cwd: "source"
          rename: (base, path) ->
            base + path.replace(/\.styl$/, ".css")
        )
        options:
          compress: false
          paths: ["node_modules/grunt-contrib-stylus/node_modules"]

    # not used since Uglify task does concat, avail if needed
    #concat: { deploy: {} },

    uglify:
      deploy:
        files:
          "<%= y.release %>/scripts/main.js": ["<%= y.src %>/scripts/{,*/}*.js"]

    useminPrepare:
      html: "<%= y.src %>/index.html"
      options:
        dest: "<%= y.release %>"

    usemin:
      html: ["<%= y.release %>/{,*/}*.html"]
      css: ["<%= y.release %>/styles/{,*/}*.css"]
      options:
        dirs: ["<%= y.release %>"]

    imagemin:
      deploy:
        files: [
          expand: true
          cwd: "<%= y.src %>/images"
          src: "{,*/}*.{png,jpg,jpeg}"
          dest: "<%= y.release %>/images"
        ]

    cssmin:
      deploy:
        files:
          "<%= y.release %>/styles/main.css": [".tmp/styles/{,*/}*.css", "<%= y.src %>/styles/{,*/}*.css"]

    htmlmin:
      deploy:
        options: {}
        files: [
          expand: true
          cwd: "<%= y.src %>"
          src: "*.html"
          dest: "<%= y.release %>"
        ]

    copy:
      release:
        files: [
          expand: true
          dot: true
          cwd: "<%= y.src %>"
          dest: "<%= y.release %>"
          src: ["logo", "*.{ico,txt}", "**/*.{,svg,png,jpg}", ".htaccess"]
        ]

    bower:
      all:
        rjsConfig: "<%= y.src %>/scripts/main.js"

  grunt.renameTask "regarde", "watch"

  grunt.registerTask "release", [
    "clean:release",
    "coffee",
    "jade:release",
    "stylus:release",
    "copy:release"
  ]

  grunt.registerTask "debug", [
    "clean:debug",
    "coffee",
    "jade:debug",
    "stylus:debug"
  ]

  grunt.registerTask "debug-run", [
    "clean:debug",
    "coffee",
    "jade:debug",
    "stylus:debug",
    "connect:livereload",
    "open",
    "livereload-start",
    "watch"
  ]
