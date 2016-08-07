{Config} = require 'docr-common'
Express = require 'express'

log = require('easylog')(module)

app = new Express()
app.use require('./routes/blob')
app.listen Config.blobPort, ->
	log.debug "Blob store listening on port http://localhost:#{Config.blobPort}"
