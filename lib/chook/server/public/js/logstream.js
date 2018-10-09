
// Vars
//////////////////////////////////
var log_stream_url = '/subscribe_to_log_stream';
var logbox = document.getElementById("logbox");
var pause_ckbx = document.getElementById("pause_log");
var log_data = '';
var log_source = new EventSource(log_stream_url);


// close the streams when client pages are closed.
// The server will see that the streams are closed
// and will close the registrations as needed.
window.onbeforeunload = function() {
   log_source.close();
   return null;
}

// Process incoming lines of data from the server
log_source.onmessage = function (event) {
  log_data = log_data + evt.data + "\n";
  write_to_logbox();
};


// toggle the updating of a logbox
function toggle_logbox() {
  write_to_logbox();
}

// stop and start the updating of the text in the textarea
function write_to_logbox() {
  if (pause_ckbx.checked) { return; }
  logbox.value = log_data;
  logbox.scrollTop = logbox.scrollHeight;
}
