// log out of basic auth by sending an incorrect name /pw
// may not work on all browsers
// see second comment at
// https://stackoverflow.com/questions/233507/how-to-log-out-user-from-web-site-using-basic-authentication#492926

function logout() {
  //var logged_out_page = window.location.protocol + '//xxxx:xxxx@' + window.location.host + '/login';

  var xhttp = new XMLHttpRequest();

  xhttp.onreadystatechange = function() {
    if (this.readyState == 4) {
      window.location = "/login";
    }
  };

  xhttp.open("GET", "/LOG_OUT:no_such_pw@logout", true);
  xhttp.setRequestHeader("Authorization", "Basic " + btoa("LOG_OUT:no_such_pw"));
  xhttp.send();
}

// show the logbox
function view_log() {
  document.getElementById("pause_log").checked = false
  document.getElementById("logbox_div").style.display = 'block';
  document.getElementById("view_log_btn").style.display = 'none';
  document.getElementById("hide_log_btn").style.display = 'inline';
  start_log_stream();
  update_logbox();
}

// hide the logbox
function hide_log() {
  document.getElementById("logbox_div").style.display = 'none';
  document.getElementById("view_log_btn").style.display = 'inline';
  document.getElementById("hide_log_btn").style.display = 'none';
  document.getElementById("pause_log").checked = true;
}

// clear the log stream
function clear_log(){
  document.getElementById("logbox").value = '';
  log_source = '';
}

// change the log level
function change_log_level() {
  var new_level = document.getElementById("log_level_select").value
  var url = "/set_log_level/" + new_level
  var xhttp = new XMLHttpRequest();
  xhttp.open("PUT", url, true);
  xhttp.send();
}

// reload the handlers
function reload_handlers() {
  var url = '/reload_handlers';
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      now = new Date().toLocaleString();
      document.getElementById("reloaded_notification").innerHTML = 'Reloaded at ' + now;
    } else {
      document.getElementById("reloaded_notification").innerHTML = 'Reload Failed.';
    }
  };
  xhttp.open("GET", url, true);
  xhttp.send();
}

// show the handler area
function view_handlers() {
  document.getElementById("handlers_div").style.display = 'block';
  document.getElementById("view_handlers_btn").style.display = 'none';
  document.getElementById("hide_handlers_btn").style.display = 'inline';
}

// hide the handler area
function hide_handlers() {
  document.getElementById("handlers_div").style.display = 'none';
  document.getElementById("view_handlers_btn").style.display = 'inline';
  document.getElementById("hide_handlers_btn").style.display = 'none';
}

// hide the handler editor
function hide_handler_viewer() {
  document.getElementById("handler_viewer_div").style.display = 'none';
}

// show the handler editor with the selected handler code
// handler = the basename of the hander fle.
function edit_handler(handler, type, named) {
  var code = '';
  var editing_filename = handler;

  // new handler
  if (handler == 'new_handler') {
    editing_filename = new_handler_filename();
    if (editing_filename == 'Name Already Taken') {
      code = editing_filename;
    }
    document.getElementById("handler_viewer").value = code;

    if (document.getElementById("add_handler_external_radio").checked) {
      type = 'external';
    } else {
      type = 'internal';
    }

  // existing handler
  } else {
    fetch_handler_code(handler) ;
  }
  if (named) {
    var now_viewing = 'Viewing named handler: ' + editing_filename + ' (' + type + ')'
  } else {
    var now_viewing = 'Viewing general handler: ' + editing_filename + ' (' + type + ')'
  }
  document.getElementById("currently_viewing_filename").innerHTML = now_viewing;
  document.getElementById("handler_viewer_div").style.display = 'block';
}

// get the code for an existing handler into the editor
function fetch_handler_code(handler) {
  var editor = document.getElementById("handler_viewer");
  var url = '/handler_code/' + handler
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      editor.value = xhttp.responseText;
    } else {
      editor.value = 'ERROR: File Not Found';
    }
  };
  xhttp.open("GET", url, true);
  xhttp.send();
}

// show the config area
function view_config() {
  document.getElementById("config_div").style.display = 'block';
  document.getElementById("view_config_btn").style.display = 'none';
  document.getElementById("hide_config_btn").style.display = 'inline';
}

// hide the config area
function hide_config() {
  document.getElementById("config_div").style.display = 'none';
  document.getElementById("view_config_btn").style.display = 'inline';
  document.getElementById("hide_config_btn").style.display = 'none';
}
