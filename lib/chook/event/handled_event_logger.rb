# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

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
      "Event #{@event.id}: #{msg}"
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

    # log an exception - multiple log lines
    # the first being the error message the rest being indented backtrace
    def log_exception(exception)
      error "#{exception.class}: #{exception}"
      exception.backtrace.each { |l| error "..#{l}" }
    end

  end # class HandledEventLogger

end # module
