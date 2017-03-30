###

 post.coffee

	These are the Express routes handling all POST requests. Front-end AJAX requests will POST here.

 Copyright (c) 2017 InterDigital, Inc. All Rights Reserved

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
###

ldap = require 'ldapjs'
path = require 'path'
mkdirp = require 'mkdirp'
moment = require 'moment'
git = {
	lib: require 'gift'
	utils: require 'git-utils'
	pull: require 'git-pull'
}

module.exports = (app) ->

	app.ldapClient = ldap.createClient({ url: 'ldap://<host>:389'})

	git_commit_push = (req, message, localPath, next) ->
		repo = git.lib localPath
		repo.commit message, { all: true, amend: false, author: "#{req.session.firstname} #{req.session.lastname} <#{req.session.email}>" }, (err) ->
			if err
				console.log err
				next err
			repo.remote_push "origin", req.session.username, next

	return {

		# Login requests, using LDAP

		"/api/login" : (req, res) ->
			app.ldapClient.bind "#{req.body.fullName}", "#{req.body.password}", (err) ->
				if err
					res.status 401
					res.json { status: err }
				else
					req.session.email = "#{req.body.fullName.split(" ")[0].toLowerCase()}@wot.io"
					req.session.lastname = req.body.fullName.split(" ")[1]
					req.session.firstname = req.body.fullName.split(" ")[0]
					req.session.username = req.body.fullName.replace " ", ""
					req.session.podsDir = path.join(__dirname, "../../../pods/#{req.session.username}")
					mkdirp.sync req.session.podsDir
					res.status 200
					res.json { status: "OK" }

		"/api/pods/:name/push" : (req, res) ->
			localPath = "#{req.session.podsDir}/bip-pod-#{req.params.name}"

			git_commit_push req, req.body.message, localPath, (err) ->
				if err
					res.status 500
					res.json { status: err }
				else
					res.status 200
					res.json { status: "Successfully Pushed to #{localPath}" }
	}
