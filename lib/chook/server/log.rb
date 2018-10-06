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
    module Log

      LOG_LEVELS = {
        fatal: Logger::FATAL,
        error: Logger::ERROR,
        warn: Logger::WARN,
        info: Logger::INFO,
        debug: Logger::DEBUG
      }.freeze

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
        @logger = Logger.new(
          Chook.config.log_file.to_s,
          Chook.config.logs_to_keep,
          (Chook.config.log_max_megs * 1024 * 1024)
        )
        @logger.datetime_format = '%Y-%m-%d %H:%M:%S'

        @logger.formatter = proc do |_severity, datetime, _progname, msg|
          "#{datetime}: #{msg}\n"
        end

        level &&= Chook::Procs::STRING_TO_LOG_LEVEL.call level
        level ||= Chook.config.log_level
        level ||= DEFAULT_LEVEL
        @logger.level = level
        @logger.unknown "Chook Server v#{Chook::VERSION} starting up. PID: #{$PROCESS_ID}, Port: #{Chook.config.port}, SSL: #{Chook.config.use_ssl}"

        # if debug, log our config
        if level == Logger::DEBUG
          @logger.debug 'Config: '
          Chook::Configuration::CONF_KEYS.keys.each do |key|
            @logger.debug "  Chook.config.#{key} = #{Chook.config.send key}"
          end
        end

        @logger
      end # log

      # general access to the logger
      def self.logger
        @logger
      end

    end # module

  end # server

  # access from everywhere as Chook.log
  def self.logger
    Server::Log.logger
  end

end # Chook
