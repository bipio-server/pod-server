###
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

String.prototype.compile = (options) ->
	str = @

	for key, value of options
		str = str.replace "{#{key}}", value
	return str

class App

	constructor: () ->
		for view, index in $('[data-view]')
			new @Views[$(view).data('view')]({ el: $(view) })

		toastr.options = {
			timeOut: 5000
		}

	Views: {

		Nav: class Nav extends Backbone.View

				initialize: () ->
					console.log "Nav view is initialized."

				events: {
					'click #nav-btn-login': 'login'
					'keyup input' : 'keyup'
					}

				keyup: (e) ->
					@login() if e.keyCode is 13

				login: () ->
					self = @
					$.post "/api/login", { fullName: $('input[name="fullName"]').val(), password: $('input[name="password"]').val() }
						.done (data) ->
							window.location.href = "/dash" if data
						.error (error) ->
							toastr.error "Invalid Credentials.", "Error"

		Dash: class Dash extends Backbone.View

				initialize: () ->
					console.log "Dash view is initialized."
					#$.each $('.bip-pod'), (index, pod) ->

		Action: class Action extends Backbone.View

				initialize: () ->
					console.log "Action view is initialized."
					@editor = ace.edit "editor"
					@editor.setTheme("ace/theme/monokai")
					@editor.getSession().setMode("ace/mode/javascript")

		Pod: class Pod extends Backbone.View

				initialize: (options) ->
					console.log "Pod view is initialized."

					$('#pod-tags').tagit()

				events: {
					'click #git_status' : 'git_status'
					'click #git_pull' : 'git_pull'
					'click #git_commit_push' : 'git_commit_push'
				}

				git_status: () ->
					self = @
					$.get "/api#{window.location.pathname}/status"
						.done (data) ->
							if data
								toastr.success data.status, "Status"

								$('#updated').text data.timestamp

				git_pull: () ->
					self = @
					$.get "/api#{window.location.pathname}/pull"
						.done (data) ->
							if data
								toastr.success data.status, "Pull"
								$('#updated').text data.timestamp
						.error (error) ->
							toastr.error error.toString(), "Error"

				git_commit_push: () ->
					self = @
					$.post "/api#{window.location.pathname}/push", { message: $('input[name="message"]').val() }
						.done (data) ->
							if data
								toastr.success data.status, "Push"
								$('#updated').text data.timestamp
						.error (error) ->
							toastr.error JSON.stringify error, "Error"

		PageError: class PageError extends Backbone.View

				initialize: () ->
					console.log "Error view is initialized."
					count = 5

					setTimeout () ->
						window.location.href = "/"
					, 5000

					setInterval () ->
						$(".redirect-timer").text(count)
						count--
					, 1000

	}

$(document).ready () ->
	new App()
