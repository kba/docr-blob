{Config} = require 'docr-common'
require 'superagent'

module.exports = \
class BlobClient

	@download: (sha1, done) ->
		sha1 = sha1.replace '^urn:sha1', ''
		Request
			.get "#{Config.blob.url}/#{sha1}"
			.end (err, res) ->
				# TODO
				done err res

