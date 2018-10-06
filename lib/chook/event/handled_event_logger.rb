### Copyright 2017 Pixar

###
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###
###    You may obtain a copy of the Apache License at
###
###        http://www.apache.org/licenses/LICENSE-2.0
###
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
###
###

module Chook

  # a simple object embedded in a Handled Event that
  # allows a standardize way to note event-related log entries
  # with the event object_id.
  #
  # Every Handled Event has one of these instances exposed in it's
  # #logger attribute, and usable from within 'internal' handlers
  #
  # Here's an example.
  #
  # Say you have a ComputerSmartGroupMembershipChanged event
  #
  # calling `event.logger.info "foobar"` will generate the log message:
  #
  #    Event 1234567: foobar
  #
  class HandledEventLogger

    def initialize(event)
      @event = event
    end

    def event_message(msg)
      "Event #{@event.object_id}: #{msg}"
    end

    def debug(msg)
      Chook::Server::Log.logger.debug event_message(msg)
    end

    def info(msg)
      Chook::Server::Log.logger.info event_message(msg)
    end

    def warn(msg)
      Chook::Server::Log.logger.warn event_message(msg)
    end

    def error(msg)
      Chook::Server::Log.logger.error event_message(msg)
    end

    def fatal(msg)
      Chook::Server::Log.logger.fatal event_message(msg)
    end

    def unknown(msg)
      Chook::Server::Log.logger.unknown event_message(msg)
    end

  end # class HandledEventLogger

end # module
