dumper = require('dumper').dumper
CSON = require('cson')
File = require('./file')

app = require("express")()


ESC = { '<': '&lt;', '>': '&gt;', '\'': '&#;', '"': '&quot;', '&': '&amp;' }
e = (s)->s.replace /[<>'"&]/g, (a)-> ESC[a]

layout = (s, p)-> 
	p ?= {}
	"""<!doctype html>
<html>
<head>
	<title>#{p.title || "нет"} | Sofia</title>
</head>
<body>
	<table style='width:100%'>
	<tr>
		<td rowspan=2>Sofia
		<td>
			<form action="/search">
				<input name='s' placeholder='Искать эон'>
			</form>
	<tr>
		<td>#{s}
	</table>
</body>
"""

# Отображает эон с диска
app.get '/aeon/:aeon', (req, res) ->

	aeon = req.params.aeon

	f = new File("pleroma/#{aeon}/aeon.cson")

	e_aeon = e aeon
	if not f.exists()
		res.send layout """
			Эона <a href="/aeon/create/#{e_aeon}">#{e_aeon}</a> нет.
		"""
	else
		a = CSON.parse f.read()

		res.send layout """

		"""

app.get '/aeon/create/:aeon', (req, res) ->
	aeon = req.params.aeon
	(await new File("pleroma/#{aeon}/aeon.cson").mkpath()).write CSON.stringify {}
	res.redirect '/aeon/#{aeon}'

port = 3000
app.listen port, ->
	console.log "Example app listening at http://localhost:#{port}"
