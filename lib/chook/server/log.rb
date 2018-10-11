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

# the main module
module Chook

  # the server app
  class Server < Sinatra::Base

    # the CustomLogger helper allows us to
    # use our own Logger instance as the
    # Sinatra `logger` available in routes vis `set :logger...`
    helpers Sinatra::CustomLogger

    # This module defines our custom Logger instance from the config settings
    # and makes it available in the .logger module method,
    # which is used anywhere outside of a route
    # (inside of a route, the #logger method is locally available)
    #
    # General access to the logger:
    #   from anywhere in Chook, as long as a server is running, the Logger
    #   instance is available at Chook.logger or Chook::Server::Log.logger
    #
    #
    # Logging from inside a route:
    #   inside a Sinatra route, the local `logger` method returnes the
    #   Logger instance.
    #
    # Logging from an internal handler:
    #  In an internal WebHook handler, starting with `Chook.event_handler do |event|`
    #  the logger should be accesses via the event's own wrapper: event.logger
    #  Each message will be prepended with the event'd ID
    #
    # Logging from an external handler:
    #  from an external handler you can POST a JSON formatted log entry to
    #  http(s)://chookserver/log. The body must be a JSON object with 2 keys:
    #  'level' and 'message', with non-empty strings.
    #  The level must be one of: fatal, error, warn, info, or debug. Any other
    #  value as the level will always be logged regardless of current logging
    #  level. NOTE: if your server requires authentication, you must provide it
    #  when using this route.
    #
    # Here's an example with curl, split to multi-line for clarity:
    #
    # curl -H "Content-Type: application/json" \
    #   -X POST \
    #   --data '{"level":"debug", "message":"It Worked"}' \
    #   https://user:passwd@chookserver.myorg.org:443/log
    #
    module Log

      # Using an instance of this as the Logger target sends logfile writes
      # to all registered streams as well as the file
      class LogFileWithStream < File

        # ServerSent Events data lines always start with this
        LOGSTREAM_DATA_PFX = 'data:'.freeze

        def write(str)
          super # writes out to the file
          flush
          # send to any active streams
          Chook::Server::Log.log_streams.keys.each do |active_stream|
            # ignore streams closed at the client end,
            # they get removed when a new stream starts
            # see the route: get '/subscribe_to_log_stream'
            next if active_stream.closed?

            # send new data to the stream
            active_stream << "#{LOGSTREAM_DATA_PFX}#{str}\n\n"
          end
        end
      end # class

      # mapping of integer levels to symbols
      LOG_LEVELS = {
        fatal: Logger::FATAL,
        error: Logger::ERROR,
        warn: Logger::WARN,
        info: Logger::INFO,
        debug: Logger::DEBUG
      }.freeze

      # log Streaming
      # ServerSent Events data lines always start with this
      LOGSTREAM_DATA_PFX = 'data:'.freeze

      # Send this to the clients at least every LOGSTREAM_KEEPALIVE_MAX secs
      # even if there's no data for the stream
      LOGSTREAM_KEEPALIVE_MSG = "#{LOGSTREAM_DATA_PFX} I'm Here!\n\n".freeze
      LOGSTREAM_KEEPALIVE_MAX = 10

      # the clients will recognize M3_LOG_STREAM_CLOSED and stop trying
      # to connect via ssh.
      LOGSTREAM_CLOSED_PFX = "#{LOGSTREAM_DATA_PFX} M3_LOG_STREAM_CLOSED:".freeze

      DEFAULT_FILE = Pathname.new '/var/log/chook-server.log'
      DEFAULT_MAX_MEGS = 10
      DEFAULT_TO_KEEP = 10
      DEFAULT_LEVEL = Logger::INFO

      # set defaults in config
      Chook.config.log_file ||= DEFAULT_FILE
      Chook.config.logs_to_keep ||= DEFAULT_TO_KEEP
      Chook.config.log_max_megs ||= DEFAULT_MAX_MEGS
      Chook.config.log_level ||= DEFAULT_LEVEL

      # Create the logger,
      # make the first log entry for this run,
      # and return it so it can be used by the server
      # when it does `set :logger, Log.startup(@log_level)`
      def self.startup(level = Chook.config.log_level)
        # create the logger using a LogFileWithStream instance
        @logger =
          if Chook.config.logs_to_keep && Chook.config.logs_to_keep > 0
            Logger.new(
              LogFileWithStream.new(Chook.config.log_file, 'a'),
              Chook.config.logs_to_keep,
              (Chook.config.log_max_megs * 1024 * 1024)
            )
          else
            Logger.new(LogFileWithStream.new(Chook.config.log_file, 'a'))
          end

        # date and line format
        @logger.datetime_format = '%Y-%m-%d %H:%M:%S'

        @logger.formatter = proc do |severity, datetime, _progname, msg|
          "#{datetime}: [#{severity}] #{msg}\n"
        end

        # level
        level &&= Chook::Procs::STRING_TO_LOG_LEVEL.call level
        level ||= Chook.config.log_level
        level ||= DEFAULT_LEVEL
        @logger.level = level

        # first startup entry
        @logger.unknown "Chook Server v#{Chook::VERSION} starting up. PID: #{$PROCESS_ID}, Port: #{Chook.config.port}, SSL: #{Chook.config.use_ssl}"

        # if debug, log our config
        if level == Logger::DEBUG
          @logger.debug 'Config: '
          Chook::Configuration::CONF_KEYS.keys.each do |key|
            @logger.debug "  Chook.config.#{key} = #{Chook.config.send key}"
          end
        end

        # return the logger, the server uses it as a helper
        @logger
      end # log

      # general access to the logger as Chook::Server::Log.logger
      def self.logger
        @logger ||= startup
      end

      # a Hash  of registered log streams
      # streams are keys, valus are their IP addrs
      # see the `get '/subscribe_to_log_stream'` route
      #
      def self.log_streams
        @log_streams ||= {}
      end

      def self.clean_log_streams
        log_streams.delete_if do |stream, ip|
          if stream.closed?
            logger.debug "Removing closed log stream for #{ip}"
            true
          else
            false
          end # if
        end # delete if
      end # clean_log_streams

    end # module

  end # server

  # access from everywhere as Chook.logger
  def self.logger
    Server::Log.logger
  end

  # log an exception - multiple log lines
  # the first being the error message the rest being indented backtrace
  def self.log_exception(exception)
    logger.error exception.to_s
    exception.backtrace.each { |l| logger.error "..#{l}" }
  end

end # Chook
