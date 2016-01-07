module.exports = function(grunt) {
	var pkg = grunt.file.readJSON('package.json');
  	require('time-grunt')(grunt);

	grunt.initConfig({
		pkg: pkg,
		copy:{
			build_game:{
				files:[{
					cwd: 'src/',
					src: ['**'], //'!**/*.{png,jpg,gif}'
					dest: 'build/',
					nonull: false,
					expand: true,
					flatten: false,
					filter: 'isFile',
				}]
			},
	    build_resources:{
		    files:[{
					cwd: 'bower_components/',
					src: [
						'LICK/lick.lua',
						'hump/camera.lua',
						'hump/gamestate.lua',
						'anim8/anim8.lua'
					],
					dest: 'build/resources/',
					nonull: false,
					expand: true,
					flatten: true,
					filter: 'isFile',
				}]
			},
		},
		watch:{
			options:{
				livereload: true,
			},
			copy:{
				files: ['src/**/*.lua','src/**/**.{png,jpg,gif}'],
				tasks: ['copy:build_game']
			}
		},
  	imagemin:{
			dynamic:{
      		files:[{
				expand: true,
				cwd: 'src/img/',
				src: ['**/*.{png,jpg,gif}'],
				dest: 'build/img/',
      		}]
    	}
		},
		sprite:{
			all: {
				src: 'temp/*.png',
				dest: 'src/img/player_placeholder.png',
        destCss: 'temp/sprites.css',
				algorithm: 'left-right'
			}
		}
	});

	grunt.loadNpmTasks('grunt-contrib-copy');
	grunt.loadNpmTasks('grunt-contrib-imagemin');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-newer');
	grunt.loadNpmTasks('grunt-spritesmith');

	grunt.registerTask('build', [
		'newer:copy:build_game',
		'newer:copy:build_resources'
	]);

	grunt.registerTask('update', [
		'copy:build_game'
	]);

	// grunt.registerTask('spritesheet', [
	// 	'sprite',
	// ]);

	grunt.registerTask('default', [
		'copy:build_game',
		'watch'
	]);

};
