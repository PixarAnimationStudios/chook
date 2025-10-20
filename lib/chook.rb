# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

# Requiring this file (require 'chook') will load the entire library
# including event testing, event handling, and the server.
#
# To load a subset, use one of:
#   require 'chook/event_testing'
#   require 'chook/event_handing'
#   require 'chook/server'

require 'chook/foundation'
require 'chook/event_testing'

# the server - it loads the event handling files
require 'chook/server'
