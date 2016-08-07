{Config} = require 'docr-common'
Express = require 'express'
Multiparty = require 'multiparty'
Crypto = require 'crypto'
Async = require 'async'
Fs = require 'fs'
Mkdirp = require 'mkdirp'

module.exports = BlobRoute = Express.Router()

BlobRoute.post '/', (req, res, next) ->
	form = new Multiparty.Form()
	form.parse req, (err, fields, fileFields) ->
		Async.eachOf fileFields, (files, fieldName, doneFileFields) ->
			Async.each files, (file, doneFile) ->
				Fs.readFile file.path, (err, data) ->
					return doneFile err if err
					file.sha1 = Crypto.createHash('sha1').update(data).digest('hex')
					Mkdirp Config.blobFolder, (err) ->
						return doneFile err if err
						Fs.writeFile "#{Config.blobFolder}/#{file.sha1}", data, (err) ->
							return doneFile err if err
							file.path = "#{Config.blobFolder}/#{file.sha1}"
							Fs.writeFile "#{file.path}.meta", JSON.stringify(file), (err) ->
								return doneFile err if err
								doneFile()
			, doneFileFields
		, (err) ->
			return next err if err
			res.send fileFields

BlobRoute.get '/:sha1', (req, res, next) ->
	fpath = "#{Config.blobFolder}/#{req.params.sha1}"
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
	fpath = "#{Config.blobFolder}/#{req.params.sha1}.meta"
	Fs.readFile fpath, (err, data) ->
		return next err if err
		res.header 'content-type', 'application/json'
		res.send data