{Config, Utils} = require 'docr-common'
Express = require 'express'
Multiparty = require 'multiparty'
Crypto = require 'crypto'
Async = require 'async'
Fs = require 'fs'
Mkdirp = require 'mkdirp'

log = require('easylog')(module)

module.exports = BlobRoute = Express.Router()

BlobRoute.post '/', (req, res, next) ->
	log.debug "POST /"
	form = new Multiparty.Form()
	form.parse req, (err, fields, fileFields) ->
		Async.eachOf fileFields, (files, fieldName, doneFileFields) ->
			Async.each files, (file, doneFile) ->
				Fs.readFile file.path, (err, data) ->
					return doneFile err if err
					file.sha1 = Crypto.createHash('sha1').update(data).digest('hex')
					Mkdirp Config.blob.folder, (err) ->
						return doneFile err if err
						Fs.writeFile "#{Config.blob.folder}/#{file.sha1}", data, (err) ->
							return doneFile err if err
							file.path = "#{Config.blob.folder}/#{file.sha1}"
							Fs.writeFile "#{file.path}.meta", JSON.stringify(file), (err) ->
								log.debug "Stored file at #{file.path}", file
								return doneFile err if err
								doneFile()
			, doneFileFields
		, (err) ->
			return next err if err
			res.send fileFields

BlobRoute.get '/:sha1', (req, res, next) ->
	log.debug "GET /#{req.params.sha1}"
	fpath = "#{Config.blob.folder}/#{Utils.cleanURI req.params.sha1}"
	metaPath = "#{fpath}.meta"
	Fs.readFile metaPath, (err,metaBytes) ->
		return next err if err
		meta = JSON.parse metaBytes
		Fs.readFile fpath, (err, data) ->
			return next err if err
			for k,v of meta.headers
				res.header k, v
			res.send data

BlobRoute.get '/:sha1/meta', (req, res, next) ->
	log.debug "GET /#{req.params.sha1}/meta"
	fpath = "#{Config.blob.folder}/#{req.params.sha1}.meta"
	Fs.readFile fpath, (err, data) ->
		return next err if err
		res.header 'content-type', 'application/json'
		res.send data
