
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
