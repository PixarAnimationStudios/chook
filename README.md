# Chook

Documentation is a work in progress. Please [get in touch](mailto:chook@pixar.com) for assistance. <3

- [Introduction](#introduction)
- [Installing Chook](#installing-chook)
- [The Server](#the-server)
	- [Server Configuration](#server-configuration)
	- [SSL](#ssl)
	- [Logging](#logging)
	- [Admin Interface](#admin-interface)
	- [Event Handlers](#event-handlers)
  	- [Internal Handlers - Ruby](#internal-handlers-ruby)
	  - [External Handlers - Any Language](#external-handlers-any-language)
	  - [Logging from handlers](#logging-from-handlers)
  - [Pointing Jamf Pro at your Chook server](#pointing-jamf-pro-at-your-chook-server)
- [The Framework](#the-framework)
	- [Events and Subjects](#events-and-subjects)
	- [Putting It Together](#putting-it-together)
- [TODOs](#todos)

## Introduction

Chook is a Ruby module that implements a framework for working with webhook events
sent by a [Jamf Pro](https://www.jamf.com/products/jamf-pro/) Server,
a management tool for Apple devices.

Chook also provides a simple [sinatra](http://sinatrarb.com/)-based HTTP server for receiving and processing those Events, and classes for sending simulated TestEvents to any Jamf webhook handling server.

**You do not need to be a Ruby developer to use Chook!**

The Chook webhook handling server can use "Event Handlers" written in
any language. See below for more information.

Although Chook integrates well with [ruby-jss](http://pixaranimationstudios.github.io/ruby-jss/index.html), especially for processing webjook events,
it's a separate tool. However, ruby-jss is required when using Jamf-based admin page authentication, or using sampling features to generate TestEvents.

For more detail about the Jamf Pro Webhooks API and the JSON data it passes, please see
[JAMF's developer reference.](http://developer.jamf.com/webhooks)

**Note:** When enabling webhooks from your Jamf Pro server to be handled by the framework, you must
specify JSON in the "Content Type" section. This framework does not support XML and
will only generate Test Events in JSON format.


## Installing Chook

As with most Ruby gems:  `gem install chook -n /usr/local/bin`

It will automatically install "sinatra" and "thin", and their dependencies.

If you'll be using a Jamf Pro server to authenticate access to Chook's admin web page, or if you'll be generating Chook TestEvents using data sampled from a Jamf Pro server you'll also need to `gem install ruby-jss`

## The Server

Chook comes with a simple HTTP(S) server that uses the Chook framework
to handle incoming webhook POST requests from a Jamf Pro server via a single URL `https://my.chookserver.org/handle_webhook_event`.

After Installing chook, just run `/usr/local/bin/chook-server` and then point your Jamf Pro webhooks at: http://my_hostname/handle_webhook_event

It will then process incoming webhook POST requests using whatever handlers
you have installed.

To automate it on a dedicated Mac, just make a LaunchDaemon plist to run
that command and keep it running.

### Server Configuration

The Chook server looks for a config file at `/etc/chook.conf`. If not found, default
values are used. Full descriptions of the config values are provided in the sample
config file at:
/path/to/your/gem/folder/chook-<version>/data/chook.conf.example

Each config setting is on a single line like: `key: value`. Blank lines and those starting with # are ignored.

Here's a summary of possible configuration keys:

 - port: The server port
   - default = 443 (SSL), or 80 (no SSL)
 - concurrency: Should events be processed simultaneously? (otherwise, one at a time)
   - default = true
 - handler_dir: The directory holding the event handler files to load.
   - default = /Library/Application Support/Chook
 - use_ssl: Should the server use SSL (https)
   - default = false
 - ssl_cert_path: If SSL is used, the path to the server certificate
   - no default
 - ssl_private_key_path: If SSL is used, the path to the certificate key
   - no default
 - log_file: The path to the server log file
   - default = /var/log/chook-server.log
 - log_level: The severity level for log entries
   - default = info
 - logs_to_keep: How many old log files to keep when rotating
   - default = 10
 - log_max_megs: How big can a log file get before it's rotated.
   - default = 10
 - webhooks_user: The username for Basic Authentication
   - no default, leave unset for no authentication
 - webhooks_user_pw: The file path, or command, to get the password for the webhooks_user.
   - no default
 - admin_user: the username for access to the Chook admin web page, or 'use_jamf'
   - no default, leave unset for no authentication
 - admin_pw: if the admin user is NOT 'use_jamf', The file path, or command, to get the password for the admin_user.
   - no default
 - admin_session_expires: How many seconds is an admin login valid?
   - default: 86400 (24 hours)
 - jamf_server: if admin_user is 'use_jamf', the Jamf Pro server to use for admin authentication
   - default: none, but /etc/ruby-jss.conf is honored.
 - jamf_port: if admin_user is 'use_jamf', the Jamf Pro server port to use for admin authentication
   - default: none, but /etc/ruby-jss.conf is honored.
 - jamf_use_ssl: if admin_user is 'use_jamf', use SSL to talk to the Jamf Pro server? true/false
   - default: none, but /etc/ruby-jss.conf is honored.
 - jamf_verify_cert: if admin_user is 'use_jamf', verify the SSL certificate from the Jamf Pro server?  true/false
   - default: none, but /etc/ruby-jss.conf is honored.
   -
See the sample config file for details about all of these settings.

### SSL

It is recommended to use SSL (https) if possible for security, although its beyond the scope
of this document to go into a lot of detail about SSL and certificates.  That said, here
are some pointers:

- The certificate and key files should be in .pem format

- Make sure you use a certificate that can be verified by the JSS.
  - This might involved adding a CA to the JSS's Java Keystore.

- If running on macOS, the 'thin' webserver and it's underlying 'eventmachine' gem may not
  like the OS's openssl replacement 'libressl'.
  - One solution is to use [homebrew](https://brew.sh/) to install openssl and then
    install eventmachine using that openssl, something like this:

    `brew install openssl ; brew link openssl --force ; gem install eventmachine -- --with-ssl-dir=/usr/local/`

### Logging

The Chook server logs activity into the file defined in the `log_file` config setting,
`/var/log/chook-server.log` by default.

It uses a standard ruby [Logger](http://ruby-doc.org/stdlib-2.3.3/libdoc/logger/rdoc/index.html)
instance, which provides 5 severity levels: fatal (lowest), error, warn, info, and debug (highest).

The `log_level` config setting defines the level when the server starts up, and log
messages of that level or lower will be written to the log.

The log can automatically rotate when it reaches a certain size, as specified by the log_max_megs configuration setting, and the logs_to_keep settings tells chook how many it should keep in total - older log files will be deleted automatically.

If you want to manage the log rotation on your own, set logs_to_keep to zero, or leave it unset,
and the log will never automatically rotate.

See below for how to write to the Chook log from within a handler

### Admin Interface

If you point your web browser at your Chook server `http(s)://your.chookserver.org/` , you'll see a simple admin interface.

If an `admin_user` is set in the configuration, you'll need to provide that name and password, or if `admin_user` is `use_jamf` you'll need to provide the username and password of any Jamf Pro user on
the server indicated in the config.

The first section provides a live-stream of the server log file, and provides a way to
change the server's log level on the fly. Note that this change affects the server itself
not just the view in your browser. If you'd like to stop the stream temporarily (e.g. to
scroll back, or select some text), just pause and unpause with the checkbox.

The second section lets you see which handlers are currently loaded, and if they are
internal or external. The (view) button shows the contents of the handler file.

There's also a button to reload the handlers from the handler directory without restarting the server - useful when you add, delete, or modify them.

The final section just shows your current /etc/chook.conf file, or if there is none,
the sample config file is shown, since it shows the default values.

The admin page cannot be used to edit or upload handlers or change the config. For security
reasons, you must do that on the server machine itself though normal administrative methods.

### Event Handlers

A handler is a file containing code to run when a webhook event is received. These
files are located in a specified directory, `/Library/Application
Support/Chook/` by default, and are loaded when the server starts, or the (reload)
button is clicked on the admin web page.

Handler files must begin with the name of the event they handle, e.g.
`ComputerAdded`, followed by: nothing, a dot, a dash, or an underscore. Handler
filenames are case-insensitive.

All of these file names are valid handlers for ComputerAdded events:

- ComputerAdded
- computeradded.sh
- COMPUTERAdded_notify_team
- Computeradded-update-ldap

Each kind of event can have as many handlers as desired, all will be executed when webhook event
is recieved. If all four of the above files existed in the handler directory, every
ComputerAdded event would run all four of them.

There are two kinds of handlers, distinguished by their file-executability.

#### Internal Handlers - Ruby

These handlers are _non-executable_ files containing Ruby code. The code is
loaded at runtime and executed as a thread in the Chook server process when
a matching event is received.

Internal handlers must be defined as a [ruby code block](http://rubylearning.com/satishtalim/ruby_blocks.html) passed to the
`Chook.event_handler` method. The block must take one parameter, the
Chook::Event subclass instance being handled. Here's a simple example of
a handler for a ComputerAdded webhook event.

```ruby
Chook.event_handler do |event|
  cname = event.subject.deviceName
  uname = event.subject.realName
  event.logger.info "Computer '#{cname}' was just added to the JSS for user #{uname}."
end
```

The code block, between `do` and `end`, takes one parameter which will be a Chook::HandledEvents::ComputerAddedEvent object. In this example the object is stored in the variable "event" and used inside the block.

This handler then extracts the "deviceName" and "realName" values from the subject
contained in the event, and uses them to log a message in the chook log.

The subject of an event is the thing that the event affected. In the case of ComputerAdded events, the subject is a Computer. In Chook, it's an object of the class Chook::HandledSubjects::ComputerAdded.

**NameSpacing**

Be careful when writing internal handlers - they all run in the same Ruby process!

Not only do they have to be thread-safe, but be wary of cluttering the default
namespace with constants or methods that might overwrite each other.

A good, very ruby-like, practice is to put the guts of your code into a Module or a Class
and use that from inside the handler definition. Here's an example using a Class:

```ruby
require 'slack-em' # ficticious Slack-chat gem, for demonstation purposes

class ComputerAdder

  SLACK_CHANNEL = '#mac-notifications'

  def initialize(event)
    @event = event
    @comp_name = @event.subject.deviceName
    @user_name = @event.subject.realName
  end

  def run
    @event.logger.info "Adder Starting for computer #{@comp_name}"
    notify_admins
    @event.logger.info "Adder Finished for computer #{@comp_name}"
  end

  def notify_admins
    msg = "Computer '#{@comp_name}' was just enrolled for user #{@user_name}."
    SlackEm.send message: msg, channel: SLACK_CHANNEL
    @event.logger.debug "Admins notified about computer #{@comp_name}"
  end

end

Chook.event_handler do |event|
  ComputerAddeder.new(event).run
end
```

Here, the handler file defines a 'ComputerAdder' class that does all the work.
The handler block merely creates an instance of ComputerAdder, passing it the event,
and tells the ComputerAdder instance to run. The instance's run method can
then perform any steps desired.

In this example, the SLACK_CHANNEL constant is defined inside the ComputerAdder class.
Access to it from inside the class is done using just the constant itself. If you
need to access that particular value from outside of the class, you can
use ComputerAdder::SLACK_CHANNEL.

This way, similar handlers can have their own SLACK_CHANNEL constants and
there won't be any interference.

For more details about event and subject classes, see [The Framework](#the-framework)

NOTE: Internal handlers **must not** be executable files. Executability is how the
framework determines if a handler is internal or external.

#### External Handlers - Any Language

External handlers are _executable_ files that are executed when called by an
event. They can be written in any language, but they must accept raw JSON on
their standard input. It's up to them to parse that JSON and react to it as
desired. In this case the Chook server is merely a conduit for passing
the Posted JSON from the Jamf Pro server to the executable program.

Here's a simple example using bash and [jq](https://stedolan.github.io/jq/) to
do something similar to the first ruby example above:

```bash
#!/bin/bash
JQ="/usr/local/bin/jq"
while read line ; do JSON="$JSON $line" ; done
cname=`echo $JSON | "$JQ" -r '.event.deviceName'`
uname=`echo $JSON | "$JQ" -r '.event.realName'`
echo "Computer '${cname}' was just added to the JSS for user ${uname}."
```

External handlers **must** be executable files. Executability is how the
framework determines if a handler is internal or external.

See `data/sample_handlers/RestAPIOperation-executable`
for a more detailed bash example that handles RestAPIOperation events.

See the [Jamf Developer Site](https://developer.jamf.com/webhooks) for details about the JSON contents of webhook events.

### Logging from handlers

**Internal handlers**

To write to the Chook log file from within an internal handler, use the `#logger` method of the `event` object
inside the handler block, like so:

```ruby
Chook.event_handler do |event|
  event.logger.debug "This line appears in the log if the level is debug"
  event.logger.info "This line appears in the log if the level is info or debug"
  event.logger.error "This line appears in the log if the level is error, warn, info, or debug"
end
```

If you want to log a Ruby exception with its backtrace, you can pass the entire
exception to the event logger's  'log_exception' method like this:
```ruby
  begin
    # something horribly wrong happens here
  rescue => execption
    event.logger.log_exception exception
  end
```

Log entries written through event objects are preceded with `Event xxxxxxxxx:`  where xxxxxxxxx is
an internal ID number for the specific even that wrote the entry.

**External handlers**

External Handlers can use a URL to make log entries by POSTing to `https://my.chookserver/log`

The request body must be a JSON object wth 2 keys 'level' and 'message' where both values are strings.

The 'level' must be one of the known log levels: fatal, error, warn, info, or debug. The message is a single line of text to be added to the log.

If your chook server is using Basic Authentication for webhook events, it must be provided for logging also.

Here's an example with curl, split to multi-line for clarity:

```
curl -u 'auth-user:auth-pw' \
  -H 'Content-Type: application/json' \
  -X POST \
  --data '{"level":"debug", "message":"It Worked"}' \
  https://chookserver.myorg.org/log
```

Messages logged via this url show up in the log preceded by `ExternalEntry: `

Any info needed to indentify a log entry with a specific event must be included in
your log message.

### Pointing Jamf Pro at your Chook server

Once your server is up and running, and you have a handler or two in place, you can create webhooks in your Jamf Pro interface:

1. Navigate to Settings => Global Management => Webhooks
2. Click "New"
3. Give your webhook a display name
4. Enter the URL for your Chook server, ending with 'handle_webhook_event', e.g:
  - `http://my.chookserver.edu/handle_webhook_event`
  - `https://my.chookserver.edu:8443/handle_webhook_event`
5. If you use Basic Authentication, enter the name and password
6. The default timeouts should be OK, but raise them a bit if you're experiencing errors.
7. Set the content type to JSON
8. Select the event that triggers the webook
9. Click "Enabled" at the top.
10. Click "Save"

Watch the Chook log, with the level at info or debug, to see events come in.

## The Framework

The Chook framework abstracts webhook Events and their components as Ruby
classes. When the JSON payload of a JSS webhook POST request is passed into the
`Chook::Event.parse_event` method, an instance of the appropriate subclass of
`Chook::Event` is returned, for example
`Chook::Event::ComputerInventoryCompletedEvent`

Each Event instance contains these important attributes:

* **webhook_id:** A read-only instance of the webhook ID stored in the JSS
  which caused the POST request. This attribute matches the "webhook[:id]"
  dictionary of the POSTed JSON.

* **webhook_name:** A read-only instance of the webhook name stored in the JSS
  which caused the POST request. This attribute matches the "webhook[:name]"
  dictionary of the POSTed JSON.

* **subject:** A read-only instance of a `Chook::Subject::<Class>`
  representing the "subject" that accompanies the event that triggered the
  webhook. It comes from the "event" dictionary of the POSTed JSON, and
  different events come with different subjects attached. For example, the
  ComputerInventoryCompleted event comes with a "computer" subject containing
  data about the JSS computer that completed inventory.

  This is not full `JSS::Computer` object from the REST API, but rather a group
  of named attributes about that computer. At the moment, only the Chook Samplers
  module attempts to look up subject data from the API, but any
  Handlers written for the event could easily do a similar operation.

* **event_json:** The JSON content from the POST request, parsed into
  a Ruby hash with symbolized keys (meaning the JSON key "deviceName" becomes
  the symbol :deviceName).

* **raw_json:** A String containing the raw JSON from the POST
  request.

* **handlers:** An Array of custom plug-ins for working with the
  event. See _Event Handlers_, below.



### Events and Subjects

Here are the Event classes supported by the framework and the Subject classes
they contain.
For details about the attributes of each Subject, see [The Unofficial JSS API
Docs](https://unofficial-jss-api-docs.atlassian.net/wiki/display/JRA/Webhooks+API).

Each Event class is a subclass of `Chook::Event`, where all of their
functionality is defined.

The Subject classes aren't subclasses, but are dynamically-defined members of
the `Chook::Subjects` module.

| Handled Event Classes | Handled Subject Classes |
| -------------- | ------------ |
| Chook::HandledEvents::ComputerAddedEvent | Chook::HandledSubjects::Computer |
| Chook::HandledEvents::ComputerCheckInEvent | Chook::HandledSubjects::Computer |
| Chook::HandledEvents::ComputerInventoryCompletedEvent | Chook::HandledSubjects::Computer |
| Chook::HandledEvents::ComputerPolicyFinishedEvent | Chook::HandledSubjects::Computer |
| Chook::HandledEvents::ComputerPushCapabilityChangedEvent | Chook::HandledSubjects::Computer |
| Chook::HandledEvents::JSSShutdownEvent | Chook::HandledSubjects::JSS |
| Chook::HandledEvents::JSSStartupEvent | Chook::HandledSubjects::JSS |
| Chook::HandledEvents::MobileDeviceCheckinEvent | Chook::HandledSubjects::MobileDevice |
| Chook::HandledEvents::MobileDeviceCommandCompletedEvent | Chook::HandledSubjects::MobileDevice |
| Chook::HandledEvents::MobileDeviceEnrolledEvent | Chook::HandledSubjects::MobileDevice |
| Chook::HandledEvents::MobileDevicePushSentEvent | Chook::HandledSubjects::MobileDevice |
| Chook::HandledEvents::MobileDeviceUnenrolledEvent | Chook::HandledSubjects::MobileDevice |
| Chook::HandledEvents::PatchSoftwareTitleUpdateEvent | Chook::HandledSubjects::PatchSoftwareTitleUpdate |
| Chook::HandledEvents::PushSentEvent | Chook::HandledSubjects::Push |
| Chook::HandledEvents::RestAPIOperationEvent | Chook::HandledSubjects::RestAPIOperation |
| Chook::HandledEvents::SCEPChallengeEvent | Chook::HandledSubjects::SCEPChallenge |
| Chook::HandledEvents::SmartGroupComputerMembershipChangeEvent | Chook::HandledSubjects::SmartGroup |
| Chook::HandledEvent::SmartGroupMobileDeviveMembershipChangeEvent | Chook::HandledSubjects::SmartGroup |

| Test Event Classes | Test Subject Classes |
| -------------- | ------------ |
| Chook::TestEvents::ComputerAddedEvent | Chook::TestSubjects::Computer |
| Chook::TestEvents::ComputerCheckInEvent | Chook::TestSubjects::Computer |
| Chook::TestEvents::ComputerInventoryCompletedEvent | Chook::TestSubjects::Computer |
| Chook::TestEvents::ComputerPolicyFinishedEvent | Chook::TestSubjects::Computer |
| Chook::TestEvents::ComputerPushCapabilityChangedEvent | Chook::TestSubjects::Computer |
| Chook::TestEvents::MobileDeviceCheckinEvent | Chook::TestSubjects::MobileDevice |
| Chook::TestEvents::MobileDeviceCommandCompletedEvent | Chook::TestSubjects::MobileDevice |
| Chook::TestEvents::MobileDeviceEnrolledEvent | Chook::TestSubjects::MobileDevice |
| Chook::TestEvents::MobileDevicePushSentEvent | Chook::TestSubjects::MobileDevice |
| Chook::TestEvents::MobileDeviceUnenrolledEvent | Chook::TestSubjects::MobileDevice |
| Chook::TestEvents::PatchSoftwareTitleUpdateEvent | Chook::TestSubjects::PatchSoftwareTitleUpdate |

### Putting It Together

Here is a commented sample of ruby code that uses the framework to process a
ComputerAdded Event:

```ruby
# load the framework
require 'chook'

# The framework comes with sample JSON files for each Event type.
# In reality, a webserver would extract this from the data POSTed from the JSS
posted_json = Chook.sample_jsons[:ComputerAdded]

# Create Chook::HandledEvents::ComputerAddedEvent instance for the event
event = Chook::HandledEvent.parse_event posted_json

# Call the events #handle method, which will execute any ComputerAdded
# handlers that were in the Handler directory when the framework was loaded.
event.handle
```

Of course, you can use the framework without using the built-in #handle method,
and if you don't have any handlers in the directory, it won't do anything
anyway. Instead you are welcome to use the objects as desired in your own
Ruby code.

## TODOs

- Better YARD docs
- Proper documentation beyond this README
