# **NOTICE:** This repository has been **DEPRECATED**. Do not use.
PodServer
=========

This is the source code for [PodServer](http://bip.wot.io:3000), a pod-management utility. Authentication through [LDAP.js](http://ldapjs.org/).

Getting Started
---------------

To run your own PodServer, you must first install the following dependencies: 

* [Node.js](http://nodejs.org/)
* [Gulp](http://gulpjs.com), installed globally using `npm install -g gulp` (may require `sudo` if permissions are wrong)

If you can run `node -v` and `gulp -v` with no errors, you can install PodServer.

Install
-------

```
git clone git@github.com:bipio-server/pod-server.git
cd pod-server && npm install
gulp
```

Project Structure
-----------------

PodServer is an [Express](http://expressjs.com/) app using [LDAP.js](http://ldapjs.org/) for authentication.

```

|- README.md
|- package.json
|- config.json 		// Contains bip.io API credentials, uses format { username: "#{bipio-username}", apiKey: "#{bipio-api-key}"}
|- gulpfile.js 		// Gulp config
|- index.js 		// JavaScript server entrypoint
|- src 				// Contains all of the coffeescript files, this is what you edit directly.
|	|- client 		// Everything here gets built and included on client side at public/scripts/client.js
|	|	|- client.coffee 
|	|
|	|- server		// Back-end node.js code
|		|- middleware 	// Express middleware to handle LDAP auth
|		|	|- index.coffee
|		|
|		|- routes 		// Express routes for loading the pages
|		|	|- get.coffee 	// GET controllers
|		|	|- post.coffee 	// POST controllers
|		|
|		|- server.coffee // Coffeescript server entrypoint
|	
|- public 			// Pubicly-accessible, static scripts and stylesheets
|	|- scripts
|	|	|- client.js // Built version of src/client/client.coffee
|	|
|	|- stylesheets
|	|	|- style.css // CSS, directly editable
|	|
|	|- vendor/ 		// Contains third-party front-end libraries like JQuery
|
|- pods/			// Contains all of the pod repositories, per user
|- node_modules/ 

``` 

Written in [CoffeScript](http://coffeescript.org/), built using [Gulp](http://gulpjs.com). 

TODO:

* Enable edits from the UI
* Build user profiles
* Install publicly on bip.wot.io:3000
* Demo

## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


Copyright (c) 2017 InterDigital, Inc. All Rights Reserved
