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

  class Server < Sinatra::Base

    helpers Sinatra::CustomLogger

    module Log

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
      def self.log
        @logger
      end

    end # module

  end # server

  # access from everywhere as Chook.log
  def self.log
    Server::Log.log
  end

end # Chook
