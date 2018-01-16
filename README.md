
# Chook

Documentation is a work in progress. Please get in touch for assistance. <3

- [Introduction](#introduction)
- [The Framework](#the-framework)
  - [Event Handlers](#event-handlers)
    - [Internal Handlers](#internal-handlers)
    - [External Handlers](#external-handlers)
  - [Putting It Together](#putting-it-together)
  - [Events and Subjects](#events-and-subjects)
- [The Server](#the-server)
- [Installing Chook](#installing-chook)
- [TODOs](#todos)


## Introduction

Chook is a Ruby module that implements a framework for working with webhook events
sent by the JSS, the core of [Jamf Pro](https://www.jamf.com/products/jamf-pro/),
a management tool for Apple devices.

Chook also provides a simple, sinatra-based HTTP server for handling those Events,
and classes for sending simulated TestEvents to a webhook handling server.

** You do not need to be a Ruby developer to use this framework! **

The webhook handling server that comes with Chook can use "Event Handlers" written in
any language. See _Event Handlers_ and _The Server_ below for more information.

Chook is still in development. While many of the basics work,
there is much to be done before it can be considered complete.

Although Chook integrates well with [ruby-jss](http://pixaranimationstudios.github.io/ruby-jss/index.html),
it's a separate tool, and the two projects aren't dependent. However, ruby-jss
does become a requirement when using sampling features to generate TestEvents.

For more detail about the JSS webhooks API and the JSON data it passes, please see
[JAMF's developer reference.](http://developer.jamf.com/webhooks)

**Note:** When creating webhooks from your JSS to be handled by the framework, you must
specify JSON in the "Content Type" section. This framework does not support XML and
will only generate Events in JSON format.

## The Framework

The Chook framework abstracts webhook Events and their components as Ruby
classes. When the JSON payload of a JSS webhook POST request is passed into the
`Chook::Event.parse_event` method, an instance of the appropriate subclass
of `Chook::Event` is returned, for example
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


### Event Handlers

A handler is a file containing code to run when a webhook event occurs. These
files are located in a specified directory, `/Library/Application
Support/Chook/` by default, and are loaded at runtime. It's up to the Jamf
administrator to create these handlers to perform desired tasks. Each class of
event can have as many handlers as desired, all will be executed when the event's
`handle` method is called.

Handler files must begin with the name of the event they handle, e.g.
ComputerAdded, followed by: nothing, a dot, a dash, or an underscore. Handler
filenames are case-insensitive.

All of these file names are valid handlers for ComputerAdded events:

- ComputerAdded
- computeradded.sh
- COMPUTERAdded_notify_team
- Computeradded-update-ldap

There are two kinds of handlers:

#### Internal Handlers

These handlers are _non-executable_ files containing Ruby code. The code is
loaded at runtime and executed in the context of the Chook Framework when
called by an event.

Internal handlers must be defined as a [ruby code block](http://rubylearning.com/satishtalim/ruby_blocks.html) passed to the
`Chook.event_handler` method. The block must take one parameter, the
Chook::Event subclass instance being handled. Here's a simple example of
a handler for a Chook::ComputerAddedEvent

```ruby
Chook.event_handler do |event|
  cname = event.subject.deviceName
  uname = event.subject.realName
  puts "Computer '#{cname}' was just added to the JSS for user #{uname}."
end
```

In this example, the code block takes one parameter, which it expects to be
a Chook::ComputerAddedEvent instance, and uses it in the variable "event."
It then extracts the "deviceName" and "realName" values from the subject
contained in the event, and uses them to send a message to stdout.

Internal handlers **must not** be executable files. Executability is how the
framework determines if a handler is internal or external.

#### External Handlers

External handlers are _executable_ files that are executed when called by an
event. They can be written in any language, but they must accept raw JSON on
their standard input. It's up to them to parse that JSON and react to it as
desired. In this case the Chook framework is merely a conduit for passing
the Posted JSON to the executable program.

Here's a simple example using bash and [jq](https://stedolan.github.io/jq/) to
do the same as the ruby example above:

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

## The Server

Chook comes with a simple HTTP server that uses the Chook framework
to handle all incoming webhook POST requests from the JSS via a single URL.

To use it you'll need the [sinatra](http://www.sinatrarb.com/)
ruby gem (`gem install sinatra`).

After that, just run the `chook-server` command located in the bin
directory for chook and then point your webhooks at:
http://my_hostname/handle_webhook_event

It will then process all incoming webhook POST requests using whatever handlers
you have installed.

To automate it on a dedicated machine, just make a LaunchDaemon plist to run
that command and keep it running.

## Installing Chook

`gem install chook -n /usr/local/bin`. It will also install "sinatra."

Then fire up `irb` and `require chook` to start playing around.

OR

run `/usr/local/bin/chook-server` and point some JSS webhooks at that machine.


## TODOs

- Add SSL support to the server
- Improved thread management for handlers
- Logging and Debug options
- Handler reloading for individual, or all, Event subclasses
- Better YARD docs
- Better namespace protection for internal handlers
- Improved configuration
- Proper documentation beyond this README
- I'm sure there's more to do...
