fs = require 'fs'
util = require 'util'

fsAccess = util.promisify(fs.access)
fsReadFile = util.promisify(fs.readFile)
fsWriteFile = util.promisify(fs.writeFile)
fsMkdir = util.promisify(fs.mkdir)

class File
	constructor: (@path) ->
	read: (args...) -> await fsReadFile @path, args...
	write: (data, args...) -> await fsWriteFile @path, data, args...
	exists: -> await fsAccess @path, fs.constants.F_OK
	mkpath: -> 
		ss = @path.split(/\//)
		if ss.length == 1 then return @
		ss.pop()
		s = ss.shift()
		for i in ss then s = "#{s}/#{i}"; fsMkdir(s)
		@


CLASS = /[A-Z]\w+/
SPACE = /[ \t]+/


module.exports = class IssaBasic
	
	constructor: ->
		@classes = {}		# классы

	# компилит конструктор
	compile_cls: (f, cls) ->

		m = new File("barsum/#{cls}/new.iss").read()

		# класс начинается с Class subclass ThisClass
		m.match /// ^ (#{CLASS}) #{SPACE} subclass #{SPACE} (#{CLASS}) \n ///


		f.write """
module.exports = class #{cls} {
	constructor() {

	}
};
"""

	# Компилит метод
	compile: (cls, method) ->
		if a = @classes[cls]?[method] then return a
		if not @classes[cls] then compile_cls cls


		# заменяем метод в файле класса
		m = new File("barsum/#{cls}/#{method}.is").read()
		
		f = new File("barsum/#{cls}/class.js")

		if not f.exists() then @compile_cls f, cls

		r = f.read()
		r = r.replace ///
			^ \t #{method} \( .*
			( ^ \t\t )*
			^ \t \}
		///m, ''
		f.write r
