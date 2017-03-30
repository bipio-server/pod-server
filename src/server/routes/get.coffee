###

 Get.coffee

	These are the Express routes handling all GET requests. All except "/" are authenticated, meaning they must first pass the auth middleware located in /src/server/middleware/index.coffee

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

fs = require 'fs'
request = require 'request'
path = require 'path'
spawn = require('child_process').spawn
moment = require 'moment'
git = {
	lib: require 'gift'
	utils: require 'git-utils'
	pull: require 'git-pull'
}
beautify = require('js-beautify').js_beautify

module.exports = (app) ->

	git_status = (localPath, next) ->
		repo = git.utils.open localPath
		status = repo.getStatus()
		status = "Up to Date" if Object.keys(status).length is 0
		next null, status if next
		return status

	git_pull = (localPath, next) ->
		git.pull localPath, (err, result) ->
			next err, result

	git_commit_push = (message, localPath, next) ->
		repo = git.lib localPath
		git.commit message, { all: true, amend: false, author: "#{req.session.firstname} #{req.session.lastname} #{req.session.email}" }, next

	git_clone = (pod, localPath, next) ->
		git.lib.clone "git://github.com/bipio-server/bip-pod-#{pod}.git", localPath, (err, repo) ->
			next err if err
			next null, "Up to Date"

	return {

		# Homepage

		"/" : (req, res) ->
			if req.session.username?
				res.redirect "/dash"
			else res.render 'index', { title: 'PodServer'}

		# Dashboard, syncs pods in /pods folder with their repositories via Git.

		"/dash": (req, res) ->
			request "http://#{app.config.username}:#{app.config.apiKey}@api.bip.io/rpc/describe/pod", (error, response, data) ->
				if error
					console.error error

				if response?.statusCode is 200
					fs.readdir req.session.podsDir, (err, localDir) ->
						pods = JSON.parse data

						for index, pod of pods
							localPath = "#{req.session.podsDir}/bip-pod-#{index}"

							if (localDir.indexOf("bip-pod-#{index}")) is -1
								pods[index].status = "current"
								((index, localPath) ->
									git_clone index, localPath, (err, status) ->
										console.error err if err
										console.log "Cloned down bip-pod-#{index} into #{localPath}"

										repo = git.lib localPath
										repo.create_branch req.session.username, (err) ->
											console.error err if err
											console.log "Created branch #{req.session.username} in #{localPath}"
											repo.checkout req.session.username, (err) ->
												console.error err if err
												console.log "Checkout branch #{req.session.username} in #{localPath}"
									)(index, localPath)
							else
								status = git_status localPath
								if status is "Up to Date"
									pods[index].status = "current"
								else
									pods[index].status = "changed"

						res.render 'dash', { title: 'PodServer', pods: pods }

		# Logout

		"/logout": (req, res) ->
			if req.session.username?
				req.session.destroy()
			res.redirect "/"

		# Pod pages

		"/pods/:name" : (req, res) ->
			request "http://#{app.config.username}:#{app.config.apiKey}@api.bip.io/rpc/describe/pod/#{req.params.name}", (error, response, data) ->
				if error
					res.redirect "/404"

				pod = JSON.parse data

				if pod.hasOwnProperty req.params.name
					localPath = "#{req.session.podsDir}/bip-pod-#{req.params.name}"
					fs.readFile "#{localPath}/manifest.json", { encoding: 'utf-8' }, (err, file) ->
						if err
							res.render 'pod', {
								title: "PodServer | #{pod[req.params.name].title}"
								manifest: null
								pod: pod[req.params.name]
								status: "Missing"
								timestamp: "Last Update: #{moment().calendar()}"
							}
						else
							manifest = JSON.parse file
							res.render 'pod', {
								title: "PodServer | #{pod[req.params.name].title}"
								manifest: manifest
								pod: pod[req.params.name]
								status: git_status localPath
								timestamp: "Last Update: #{moment().calendar()}"
							}
				else
					res.redirect "/404"

		"/pods/:name/:action" : (req, res) ->
			localPath = "#{req.session.podsDir}/bip-pod-#{req.params.name}"
			fs.readFile "#{localPath}/manifest.json", { encoding: 'utf-8' }, (err, file) ->
				if err
					res.redirect "/404"
				else
					manifest = JSON.parse file
					if manifest.actions.hasOwnProperty req.params.action
						fs.readFile "#{localPath}/#{req.params.action}.js", { encoding: 'utf-8' }, (err, file) ->
							if err
								res.redirect "/404"
							else
								res.render 'action', { title: "PodServer | #{req.params.name}.#{req.params.action}", code: beautify(file, { indent_size: 4 }) }
					else
						res.redirect "/404"

		# 404s and such

		"/404" : (req, res) ->
			res.render "error", { title: 'PodServer' }

		# Pod status

		"/api/pods/:name/status" : (req, res) ->
			localPath = "#{req.session.podsDir}/bip-pod-#{req.params.name}"
			git_status localPath, (err, status) ->
				res.redirect "404" if err
				res.json {
					status: status
					timestamp: "Last Update: #{moment().calendar()}"
				}

		"/api/pods/:name/pull" : (req, res) ->
			localPath = "#{req.session.podsDir}/bip-pod-#{req.params.name}"
			git_pull localPath, (err, status) ->
				res.redirect "404" if err
				res.json {
					status: status
					timestamp: "Last Update: #{moment().calendar()}"
				}

		"/api/pods/:name/:file" : (req, res) ->
			localPath = "#{req.session.podsDir}/bip-pod-#{req.params.name}"
			fs.readFile "#{localPath}/#{req.params.file}", { encoding: 'utf-8' }, (err, file) ->
				if err
					res.json { status: "File not found" }
				else
					res.json { name: req.params.file, file: if path.extname(req.params.file) is '.json' then JSON.parse(file) else beautify(file, { indent_size: 4 }) }

	}
