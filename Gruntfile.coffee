# vim: ts=2 sw=2 et :
"use strict"
lrSnippet = require("grunt-contrib-livereload/lib/utils").livereloadSnippet
mountFolder = (connect, dir) ->
	connect.static require("path").resolve(dir)

# Global _c_onfig varible to hold source folder and destination for release 
c = source: "source", release: "release", tmp: ".tmp"

# Globbing for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to match all subfolders:
# 'test/spec/**/*.js'
 
module.exports = (grunt) ->

	# load all grunt tasks
	require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks

	grunt.initConfig
		watch:
			coffee:
				files: [c.source + "/scripts/{,*/}*.coffee"]
				tasks: ["coffee:deploy"]

			coffeeTest:
				files: ["test/spec/{,*/}*.coffee"]
				tasks: ["coffee:test"]

			jade:
				files: [c.source + "/*.jade"]
				tasks: ["jade:debug"]

			stylus:
				files: [c.source + "/*.styl"]
				tasks: ["stylus:debug"]

			livereload:
				files: [".tmp/*.html", ".tmp/*.css", 
						".tmp/scripts/{,*/}*.js", c.source + "/images/{,*/}*.{png,svg,jpg,jpeg,webp}"]
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
						mountFolder(connect, c.source) 
					]

		open:
			server:
				path: "http://localhost:<%= connect.options.port %>"

		clean:
			release: [".tmp", c.release ]
			debug: ".tmp"

		jshint:
			options:
				jshintrc: ".jshintrc"

			all: ["Gruntfile.js", c.source + "/scripts/{,*/}*.js", 
				"!" + c.source + "/scripts/vendor/*", "test/spec/{,*/}*.js"]

		coffee:
			deploy:
				files: [

					# rather than compiling multiple files here you should
					# require them into your main .coffee file
					expand: true
					cwd: c.source + "/scripts"
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
				files: grunt.file.expandMapping(["*.jade"], c.release + "/",
					cwd: c.source
					rename: (base, path) ->
						base + path.replace(/\.jade$/, ".html")
				)
				options:
					client: false
					pretty: false
					data:
						title: "gruntfile release"

			debug:
				files: grunt.file.expandMapping(["*.jade"], c.tmp + "/",
					cwd: c.source
					rename: (base, path) ->
						base + path.replace(/\.jade$/, ".html")
				)
				options:
					client: false
					pretty: true
					data:
						title: "gruntfile debug"

		stylus:
			release:
				files: grunt.file.expandMapping(["*.styl"], c.release + "/",
					cwd: c.source
					rename: (base, path) ->
						base + path.replace(/\.styl$/, ".css")
				)
				options:
					compress: true
					paths: ["node_modules/grunt-contrib-stylus/node_modules"]

			debug:
				files: grunt.file.expandMapping(["*.styl"], c.tmp + "/",
					cwd: c.source
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
					c.release + "/scripts/main.js": [c.source + "/scripts/{,*/}*.js"]

		useminPrepare:
			html: c.source + "/index.html"
			options:
				dest: c.release

		usemin:
			html: [c.release + "/{,*/}*.html"]
			css: [c.release + "/styles/{,*/}*.css"]
			options:
				dirs: [c.release]

		imagemin:
			deploy:
				files: [
					expand: true
					cwd: c.source + "/images"
					src: "{,*/}*.{png,jpg,jpeg}"
					dest: c.release + "/images"
				]

		cssmin:
			deploy:
				files:
					c.source + "/styles/main.css": [".tmp/styles/{,*/}*.css", c.source + "/styles/{,*/}*.css"]

		htmlmin:
			deploy:
				options: {}
				files: [
					expand: true
					cwd: c.source
					src: "*.html"
					dest: c.release
				]

		copy:
			release:
				files: [
					expand: true
					dot: true
					cwd: c.source
					dest: c.release
					src: ["logo", "*.{ico,txt}", "**/*.{,svg,png,jpg}", ".htaccess"]
				]

		bower:
			all:
				rjsConfig: c.source + "/scripts/main.js"

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

	grunt.registerTask "default", ["debug-run"]

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

