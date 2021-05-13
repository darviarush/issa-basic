Fs = require("fs")
fs = Fs.promises

module.exports = class File
	constructor: (@path) ->
	read: (args...) -> 
		await fs.readFile @path, args...
		@
	write: (data, args...) -> 
		await fs.writeFile @path, data, args...
		@
	exists: -> await fs.exists @path
	mkpath: -> 
		s = @path.split("/")[..-1].join("/")
		await fs.mkdirSync s, { recursive: true }
		@