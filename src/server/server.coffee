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

express			= require("express")
path			= require("path")
moment 			= require('moment')
colors 			= require('colors')
bodyParser 		= require 'body-parser'
cookieParser 	= require 'cookie-parser'
session			= require 'express-session'
request 		= require 'request'

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0'

routes = {
	get: require('./routes/get')
	post: require('./routes/post')
	}
middleware = require('./middleware')

#	Set the app
app	= express()
app.config = require '../../config'

#	Set the server port
app.set 'port', 3000
app.set 'version', require('../../package').version
app.set 'name', require('../../package').name

#	Configure jade templates
app.set 'views', path.join __dirname, "../../views"
app.set "view engine", "jade"

#	Configure client-side
app.use express.static path.join __dirname, "../../public"

app.use cookieParser()
app.use session { secret: '934b7dec-705d-4f5d-b0ee-e2d68782b67d', cookie: { maxAge: 3600000 } }
app.use bodyParser.json()
app.use bodyParser.urlencoded { extended: true }

#	Create the server with timestamp
server = require('http').createServer(app)
server.listen app.get("port"), ->
	timestamp = moment().format('D MMM H:mm:ss')
	console.log "%s - %s v%s ("+"%s".blue+") port "+"%d".red, timestamp, app.get('name'), app.get('version'), app.get('env'), app.get('port')

# Configure middleware
app.use route, method for route, method of middleware app

# Configure normal http routes
app.get route, method for route, method of routes.get app
app.post route, method for route, method of routes.post app

#	Handle crashes
process.on 'SIGINT', ->
  setTimeout ->
    console.error "Forcefully shutting down".red
    process.exit(1)
  , 1000

module.exports = app
