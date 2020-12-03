# Chook Change Log

## v 1.1.4, 2020-08-10

- Set the server process name to 'chook'  - some OS utilities will see it
- remove event START messages from info logging, now only visible when log level is debug.
- Don't use ruby object IDs as event ids - ruby reuses them.
- Server uptime is displayed on the simple admin web UI.

## v 1.1.3, 2019-10-28

- Named Handlers!  You can create a handler with any file name, and put it in /Library/Application Support/Chook/NamedHandlers  then call it specifically from a webhook in Jamf Pro using the url http[s]://your.chook.server.com/handler/handler-filename

## v 1.1.2,  2019-01-24

- code cleanup & bugfixes

- thread ids show up in debug logging

- go back to calling Thread.new explicitly, so that the JSS gets immediate acknowlegment of reciept of the POST

- don't use sessions for the event-handling route

- update README.md to be more server focused, since thats the primary use of Chook

## v 1.1.1,  2018-10-18

- Admin web page authentication is now separated from Webhooks HTTP Basic Auth.
  It can be turned off completely, set to a single username/password, or pointed
  at a Jamf Pro server for admin authentication. See the Admin Interface section
  of README.md, and/or chook.conf.example for details.

## v 1.1.0,  2018-10-15

For details about the new features, please see README.md

- Now requires 'thin' as the server engine.

- Supports SSL and HTTP Basic Authentication

- Server logging is now a thing, with access to logging from both internal and external handlers

- A simple admin interface is available by pointing your browser at the chook server

- Internal handlers are now stored as anonymous objects rather than Procs, and the handler code block
  is stored as an instance method on the object. This means that either 'break' or 'return' will work
  to exit a handler.
