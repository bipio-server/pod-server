/**
 *
 * Copyright (c) 2017 InterDigital, Inc. All Rights Reserved
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

var App,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __hasProp = {}.hasOwnProperty;

String.prototype.compile = function(options) {
  var key, str, value;
  str = this;
  for (key in options) {
    value = options[key];
    str = str.replace("{" + key + "}", value);
  }
  return str;
};

App = (function() {
  var Action, Dash, Nav, PageError, Pod;

  function App() {
    var index, view, _i, _len, _ref;
    _ref = $('[data-view]');
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      view = _ref[index];
      new this.Views[$(view).data('view')]({
        el: $(view)
      });
    }
    toastr.options = {
      timeOut: 5000
    };
  }

  App.prototype.Views = {
    Nav: Nav = (function(_super) {
      __extends(Nav, _super);

      function Nav() {
        return Nav.__super__.constructor.apply(this, arguments);
      }

      Nav.prototype.initialize = function() {
        return console.log("Nav view is initialized.");
      };

      Nav.prototype.events = {
        'click #nav-btn-login': 'login',
        'keyup input': 'keyup'
      };

      Nav.prototype.keyup = function(e) {
        if (e.keyCode === 13) {
          return this.login();
        }
      };

      Nav.prototype.login = function() {
        var self;
        self = this;
        return $.post("/api/login", {
          fullName: $('input[name="fullName"]').val(),
          password: $('input[name="password"]').val()
        }).done(function(data) {
          if (data) {
            return window.location.href = "/dash";
          }
        }).error(function(error) {
          return toastr.error("Invalid Credentials.", "Error");
        });
      };

      return Nav;

    })(Backbone.View),
    Dash: Dash = (function(_super) {
      __extends(Dash, _super);

      function Dash() {
        return Dash.__super__.constructor.apply(this, arguments);
      }

      Dash.prototype.initialize = function() {
        return console.log("Dash view is initialized.");
      };

      return Dash;

    })(Backbone.View),
    Action: Action = (function(_super) {
      __extends(Action, _super);

      function Action() {
        return Action.__super__.constructor.apply(this, arguments);
      }

      Action.prototype.initialize = function() {
        console.log("Action view is initialized.");
        this.editor = ace.edit("editor");
        this.editor.setTheme("ace/theme/monokai");
        return this.editor.getSession().setMode("ace/mode/javascript");
      };

      return Action;

    })(Backbone.View),
    Pod: Pod = (function(_super) {
      __extends(Pod, _super);

      function Pod() {
        return Pod.__super__.constructor.apply(this, arguments);
      }

      Pod.prototype.initialize = function(options) {
        console.log("Pod view is initialized.");
        return $('#pod-tags').tagit();
      };

      Pod.prototype.events = {
        'click #git_status': 'git_status',
        'click #git_pull': 'git_pull',
        'click #git_commit_push': 'git_commit_push'
      };

      Pod.prototype.git_status = function() {
        var self;
        self = this;
        return $.get("/api" + window.location.pathname + "/status").done(function(data) {
          if (data) {
            toastr.success(data.status, "Status");
            return $('#updated').text(data.timestamp);
          }
        });
      };

      Pod.prototype.git_pull = function() {
        var self;
        self = this;
        return $.get("/api" + window.location.pathname + "/pull").done(function(data) {
          if (data) {
            toastr.success(data.status, "Pull");
            return $('#updated').text(data.timestamp);
          }
        }).error(function(error) {
          return toastr.error(error.toString(), "Error");
        });
      };

      Pod.prototype.git_commit_push = function() {
        var self;
        self = this;
        return $.post("/api" + window.location.pathname + "/push", {
          message: $('input[name="message"]').val()
        }).done(function(data) {
          if (data) {
            toastr.success(data.status, "Push");
            return $('#updated').text(data.timestamp);
          }
        }).error(function(error) {
          return toastr.error(JSON.stringify(error, "Error"));
        });
      };

      return Pod;

    })(Backbone.View),
    PageError: PageError = (function(_super) {
      __extends(PageError, _super);

      function PageError() {
        return PageError.__super__.constructor.apply(this, arguments);
      }

      PageError.prototype.initialize = function() {
        var count;
        console.log("Error view is initialized.");
        count = 5;
        setTimeout(function() {
          return window.location.href = "/";
        }, 5000);
        return setInterval(function() {
          $(".redirect-timer").text(count);
          return count--;
        }, 1000);
      };

      return PageError;

    })(Backbone.View)
  };

  return App;

})();

$(document).ready(function() {
  return new App();
});
