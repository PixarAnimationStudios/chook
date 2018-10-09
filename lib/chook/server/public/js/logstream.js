
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

// update the text in the log box unless the
// pause checkbox is checked
function update_logbox() {
  if (pause_ckbx.checked) { return; }
  logbox.value = log_data;
  logbox.scrollTop = logbox.scrollHeight;
}

// start the stream
function start_log_stream() {
  // return if already started
  if (typeof(log_source) != "undefined")  { return; }

  logbox = document.getElementById("logbox");
  pause_ckbx = document.getElementById("pause_log");

  log_data = logbox.value;
  log_source = new EventSource(log_stream_url);

  // add incoming lines of data from the server
  // to the in-memory cache
  log_source.onmessage = function (event) {
    log_data = log_data + event.data + "\n";
    update_logbox();
  };

  // close the streams when client pages are closed.
  // The server will see that the streams are closed
  // and will remove the registrations as needed.
  window.onbeforeunload = function() {
     log_source.close();
     return null;
  }
}
