{client} = require '../lib'
# client.download 'https://avatars1.githubusercontent.com/u/273367?v=3&s=40', {abspath: '/tmp/test'}, (err) ->
	# console.log arguments
client.upload '/tmp/test', {contentType: 'image/png'}, -> console.log arguments
client.download 'urn:sha1:54aa8b4be8885b092cda900ef9623d65a50d8102', {abspath: '/tmp/test2'}, (err) ->
