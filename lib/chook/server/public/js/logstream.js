
// Vars
//////////////////////////////////

// the url that will provide the stream
var log_stream_url = '/subscribe_to_log_stream';

// the EventSource that will get events from the url
var log_source

// the log box on the info page
var logbox

// the checkbox to pause updating the log box
var pause_ckbx

// data from the log gets added to this string
// but its only written to the log box if we
// aren't paused.
var log_data

var new_log_level_regex = /Log level changed, now: (.*)$/;

// update the text in the log box unless the
// pause checkbox is checked
function update_logbox() {
  if (pause_ckbx.checked) { return; }
  logbox.value = log_data;
  logbox.scrollTop = logbox.scrollHeight;
}

// start the stream
function start_log_stream() {
  // always update the log level
  get_current_log_level();
  // return if already started
  if (typeof(log_source) != "undefined")  { return; }

  logbox = document.getElementById("logbox");
  pause_ckbx = document.getElementById("pause_log");

  log_data = logbox.value;
  log_source = new EventSource(log_stream_url);

  // add incoming lines of data from the server
  // to the in-memory cache
  log_source.onmessage = function (event) {
    var msg = event.data;
    log_data = log_data + msg + "\n";
    update_logbox();
    var match = new_log_level_regex.exec(msg);
    if (match) { update_log_level_selector(match[1]); }
  };

  // close the streams when client pages are closed.
  // The server will see that the streams are closed
  // and will remove the registrations as needed.
  window.onbeforeunload = function() {
     log_source.close();
     return null;
  }
}

// update the selector with the current log level from the server
function get_current_log_level() {
  var url = '/current_log_level';
  var xhttp = new XMLHttpRequest();

  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      update_log_level_selector(xhttp.responseText);
    }
  };

  xhttp.open("GET", url, true);
  xhttp.send();
}

function update_log_level_selector(new_level) {
  var new_idx;
  switch(new_level) {
    case 'fatal':
      new_idx = 0;
      break;
    case 'error':
      new_idx = 1;
      break;
    case 'warn':
      new_idx = 2;
      break;
    case 'info':
      new_idx = 3;
      break;
    case 'debug':
      new_idx = 4;
      break;
    default:
      new_idx = null;
   }
  document.getElementById("log_level_select").selectedIndex = new_idx;
}
