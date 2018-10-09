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

require 'sinatra/base'
require 'sinatra/custom_logger'
# require 'haml'
require 'openssl'
require 'chook/event_handling'
require 'chook/server/log'
require 'chook/server/routes'

module Chook

  # The chook server is a basic sinatra server running on
  # the engine of your choice.
  class Server < Sinatra::Base

    DEFAULT_SERVER_ENGINE = :webrick
    DEFAULT_PORT = 80
    DEFAULT_SSL_PORT = 443
    DEFAULT_CONCURRENCY = true

    # set defaults in config
    Chook.config.engine ||= DEFAULT_SERVER_ENGINE
    Chook.config.port ||= Chook.config.use_ssl ? DEFAULT_SSL_PORT : DEFAULT_PORT

    # can't use ||= here cuz nil and false have different meanings
    Chook.config.concurrency = DEFAULT_CONCURRENCY if Chook.config.concurrency.nil?

    # Run the server
    ###################################
    def self.run!(log_level: nil)
      log_level ||= Chook.config.log_level
      @log_level = Chook::Procs::STRING_TO_LOG_LEVEL.call log_level

      chook_configure

      Chook::HandledEvent::Handlers.load_handlers

      case Chook.config.engine.to_sym
      when :webrick
        Chook.logger.warn 'SSL not available with webrick engine, please install thin' if Chook.config.use_ssl
        super
      when :thin
        if Chook.config.use_ssl
          super do |server|
            server.ssl = true
            server.ssl_options = {
              cert_chain_file: Chook.config.ssl_cert_path.to_s,
              private_key_file: Chook.config.ssl_private_key_path.to_s,
              verify_peer: false
            }
          end # super do
        else
          super
        end # if use ssl
      end # case
    end # self.run

    # Configure the server
    ###################################
    def self.chook_configure
      configure do
        set :logger, Log.startup(@log_level)
        set :bind, '0.0.0.0'
        set :server, Chook.config.engine
        set :port, Chook.config.port
        enable :lock unless Chook.config.concurrency
        set :show_exceptions, :after_handler if development?
      end # configure

      return unless Chook.config.webhooks_user

      # turn on HTTP basic auth
      @webhooks_user_pw = webhooks_user_pw
      use Rack::Auth::Basic, 'Restricted Area' do |username, password|
        (username == Chook.config.webhooks_user) && (password.chomp == @webhooks_user_pw)
      end
    end # chook_configure

    # Learn the client password
    ###################################
    def self.webhooks_user_pw
      return nil unless Chook.config.webhooks_user_pw

      setting = Chook.config.webhooks_user_pw

      # if the path ends with a pipe, its a command that will
      # return the desired password, so remove the pipe,
      # execute it, and return stdout from it.
      if setting.end_with? '|'
        cmd = setting.chomp '|'
        output = `#{cmd} 2>&1`.chomp
        raise "Can't get webhooks user password: #{output}" unless $CHILD_STATUS.exitstatus.zero?
        output
      else
        # otherwise its a file path, and read the pw from the contents
        file = Pathname.new setting
        return nil unless file.file?
        stat = file.stat
        mode = format('%o', stat.mode)
        raise 'Password file for webhooks user has insecure mode, must be 0600.' unless mode.end_with?('0600')
        raise "Password file for webhooks user has insecure owner, must be owned by UID #{Process.euid}." unless stat.owned?

        # chomping an empty string removes all trailing \n's and \r\n's
        file.read.chomp('')
      end # if else
    end # self.webhooks_user_pw

  end # class server

end # module
