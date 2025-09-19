### Copyright 2025 Pixar

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
require 'haml'
require 'openssl'
require 'chook/event_handling'
require 'chook/server/log'
require 'chook/server/auth'
require 'chook/server/routes'

module Chook

  # The chook server is a basic sinatra server running on
  # the engine of your choice.
  class Server < Sinatra::Base

    DEFAULT_PORT = 80
    DEFAULT_SSL_PORT = 443
    DEFAULT_CONCURRENCY = true
    DEFAULT_SESSION_EXPIRE = 24 * 60 * 60 # one day

    CHOOK_LOGO_URL = 'https://pixaranimationstudios.github.io/chook/images/Chook_Al_McWhiggin_Logo_Web.png'.freeze

    # set defaults in config
    Chook.config.port ||= Chook.config.use_ssl ? DEFAULT_SSL_PORT : DEFAULT_PORT
    Chook.config.admin_session_expires ||= DEFAULT_SESSION_EXPIRE

    # can't use ||= here cuz nil and false have different meanings
    Chook.config.concurrency = DEFAULT_CONCURRENCY if Chook.config.concurrency.nil?

    # Run the server
    ###################################
    def self.run!(log_level: nil)
      prep_to_run

      if Chook.config.use_ssl
        super do |server|
          server.ssl = true
          server.ssl_options = {
            cert_chain_file: Chook.config.ssl_cert_path.to_s,
            private_key_file: Chook.config.ssl_private_key_path.to_s,
            verify_peer: false
          }
        end # super do

      else # no ssl
        super
      end # if use ssl
    end # self.run

    def self.prep_to_run
      @start_time = Time.now
      log_level ||= Chook.config.log_level
      @log_level = Chook::Procs::STRING_TO_LOG_LEVEL.call log_level

      configure do
        set :logger, Log.startup(@log_level)
        set :server, :thin
        set :bind, '0.0.0.0'
        set :port, Chook.config.port
        set :show_exceptions, :after_handler if development?
        set :root, "#{File.dirname __FILE__}/server"
        enable :static
        enable :sessions
        set :sessions, expire_after: Chook.config.admin_session_expires if Chook.config.admin_user
        if Chook.config.concurrency
          set :threaded, true
        else
          enable :lock
        end
      end # configure

      Chook::HandledEvent::Handlers.load_handlers
    end # prep to run

    def self.starttime
      @start_time
    end

    def self.uptime
      @start_time ? "#{humanize_secs(Time.now - @start_time)} ago" : 'Not Running'
    end

    # Very handy!
    # lifted from
    # http://stackoverflow.com/questions/4136248/how-to-generate-a-human-readable-time-range-using-ruby-on-rails
    #
    def self.humanize_secs(secs)
      [[60, :second], [60, :minute], [24, :hour], [7, :day], [52.179, :week], [1_000_000, :year]].map do |count, name|
        next unless secs.positive?

        secs, n = secs.divmod(count)
        n = n.to_i
        "#{n} #{n == 1 ? name : (name.to_s + 's')}"
      end.compact.reverse.join(' ')
    end

  end # class server

end # module
