Request = require 'request'

Request
	method: 'GET'
	url: 'http://google.com'
	, (err, res, body) ->
		console.log arguments
