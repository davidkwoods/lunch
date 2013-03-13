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
    app: "app"
    deploy: "deploy"

  grunt.initConfig
    yeoman: yeomanConfig
    watch:
      coffee:
        files: ["<%= yeoman.app %>/scripts/{,*/}*.coffee"]
        tasks: ["coffee:deploy"]

      coffeeTest:
        files: ["test/spec/{,*/}*.coffee"]
        tasks: ["coffee:test"]

      jade:
        files: ["<%= yeoman.app %>/*.jade"]
        tasks: ["jade:deploy"]

      stylus:
        files: ["<%= yeoman.app %>/*.styl"]
        tasks: ["styl:deploy"]

      livereload:
        files: ["<%= yeoman.deploy %>/*.html", "{.tmp,<%= yeoman.deploy %>}/styles/{,*/}*.css", "{.tmp,<%= yeoman.deploy %>}/scripts/{,*/}*.js", "<%= yeoman.deploy %>/images/{,*/}*.{png,jpg,jpeg,webp}"]
        tasks: ["livereload"]

    connect:
      options:
        port: 9000
        
        # change this to '0.0.0.0' to access the server from outside
        hostname: "localhost"

      livereload:
        options:
          middleware: (connect) ->
            [lrSnippet, mountFolder(connect, ".tmp"), mountFolder(connect, "deploy")]

      test:
        options:
          middleware: (connect) ->
            [mountFolder(connect, ".tmp"), mountFolder(connect, "test")]

      deploy:
        options:
          middleware: (connect) ->
            [mountFolder(connect, "deploy")]

    open:
      server:
        path: "http://localhost:<%= connect.options.port %>"

    clean:
      deploy: [".tmp", "<%= yeoman.deploy %>/*"]
      server: ".tmp"

    jshint:
      options:
        jshintrc: ".jshintrc"

      all: ["Gruntfile.js", "<%= yeoman.app %>/scripts/{,*/}*.js", "!<%= yeoman.app %>/scripts/vendor/*", "test/spec/{,*/}*.js"]

    coffee:
      deploy:
        files: [
          
          # rather than compiling multiple files here you should
          # require them into your main .coffee file
          expand: true
          cwd: "<%= yeoman.app %>/scripts"
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
      deploy:
        files: grunt.file.expandMapping(["*.jade"], "deploy/",
          cwd: "app"
          rename: (base, path) ->
            base + path.replace(/\.jade$/, ".html")
        )
        options:
          client: false
          pretty: false
          data:
            title: "hello from gruntfile"

      server:
        files: grunt.file.expandMapping(["*.jade"], "deploy/",
          cwd: "app"
          rename: (base, path) ->
            base + path.replace(/\.jade$/, ".html")
        )
        options:
          client: false
          pretty: true
          data:
            title: "hello from gruntfile"

    stylus:
      all:
        files: grunt.file.expandMapping(["*.styl"], "deploy/",
          cwd: "app"
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
          "<%= yeoman.deploy %>/scripts/main.js": ["<%= yeoman.app %>/scripts/{,*/}*.js"]

    useminPrepare:
      html: "<%= yeoman.app %>/index.html"
      options:
        dest: "<%= yeoman.deploy %>"

    usemin:
      html: ["<%= yeoman.deploy %>/{,*/}*.html"]
      css: ["<%= yeoman.deploy %>/styles/{,*/}*.css"]
      options:
        dirs: ["<%= yeoman.deploy %>"]

    imagemin:
      deploy:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/images"
          src: "{,*/}*.{png,jpg,jpeg}"
          dest: "<%= yeoman.deploy %>/images"
        ]

    cssmin:
      deploy:
        files:
          "<%= yeoman.deploy %>/styles/main.css": [".tmp/styles/{,*/}*.css", "<%= yeoman.app %>/styles/{,*/}*.css"]

    htmlmin:
      deploy:
        options: {}
        files: [
          expand: true
          cwd: "<%= yeoman.app %>"
          src: "*.html"
          dest: "<%= yeoman.deploy %>"
        ]

    copy:
      deploy:
        files: [
          expand: true
          dot: true
          cwd: "<%= yeoman.app %>"
          dest: "<%= yeoman.deploy %>"
          src: ["*.{ico,txt}", ".htaccess"]
        ]

      server:
        files: [
          expand: true
          dot: true
          cwd: "<%= yeoman.app %>"
          dest: "<%= yeoman.deploy %>"
          src: ["logo", "*.{ico,txt}", "*.html", "**/*.{css,svg,png,jpg}", ".htaccess"]
        ]

    bower:
      all:
        rjsConfig: "<%= yeoman.app %>/scripts/main.js"

  grunt.renameTask "regarde", "watch"

  grunt.registerTask "server", (target) ->
    return grunt.task.run(["build", "open", "connect:deploy:keepalive"])  if target is "deploy"
    grunt.task.run [
        "clean:server", 
        "coffee:deploy", 
        "jade", 
        "stylus", 
        "livereload-start", 
        "connect:livereload", 
        "open", 
        "watch"]

  grunt.registerTask "scott", [
      "clean:deploy", 
      "coffee", 
      "jade", 
      "stylus", 
      "imagemin", 
      "copy:server", 
      "livereload-start", 
      "open", 
      "connect:livereload", 
      "watch"
  ]

  grunt.registerTask "build", ["clean:deploy", "coffee", "jade", "stylus", 
      "useminPrepare", "imagemin", "htmlmin", "cssmin", "uglify", "copy:deploy", "usemin"]

  grunt.registerTask "default", ["jshint", "build"]
