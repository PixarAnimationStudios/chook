# Chook Change Log

## v 1.1.0,  2018-10-15

For details about the new features, please see README.md

- Now requires 'thin' as the server engine.


- Supports SSL and HTTP Basic Authentication


- Server logging is now a thing, with access to logging from both internal and external handlers


- A simple admin interface is available by pointing your browser at the chook server


- Internal handlers are now stored as anonymous objects rather than Procs, and the handler code block
  is stored as an instance method on the object. This means that either 'break' or 'return' will work
  to exit a handler.
