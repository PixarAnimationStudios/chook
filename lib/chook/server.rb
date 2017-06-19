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
require 'chook/event_handling'
require 'sinatra/base'
require 'openssl'

module Chook

  # The chook server is a basic sinatra server running on
  # the engine of your choice.
  class Server < Sinatra::Base

    DEFAULT_SERVER_ENGINE = :webrick
    DEFAULT_PORT = 8000

    @server_engine = Chook::CONFIG.server_engine || DEFAULT_SERVER_ENGINE
    require @server_engine.to_s
    @server_port = Chook::CONFIG.server_port || DEFAULT_PORT

    def self.run!
      chook_configure
      case @server_engine.to_sym
      when :webrick
        super
      when :thin
        if Chook::CONFIG.use_ssl
          super do |server|
            server.ssl = true
            server.ssl_options = {
              cert_chain_file: Chook::CONFIG.ssl_cert_path.to_s,
              private_key_file: Chook::CONFIG.ssl_private_key_path.to_s,
              verify_peer: false
            }
          end # super do
        else
          super
        end # if use ssl
      end # case
    end # self.run

    # Sinatra Settings
    def self.chook_configure
      configure do
        set :environment, :production
        enable :logging, :lock
        set :bind, '0.0.0.0'
        set :server, @server_engine
        set :port, @server_port

        if Chook::CONFIG.use_ssl
          case @server_engine.to_sym
          when :webrick
            require 'webrick/https'
            key = Chook::CONFIG.ssl_private_key_path.read
            cert = Chook::CONFIG.ssl_cert_path.read
            cert_name = Chook::CONFIG.ssl_cert_name
            set :SSLEnable, true
            set :SSLVerifyClient, OpenSSL::SSL::VERIFY_NONE
            set :SSLPrivateKey, OpenSSL::PKey::RSA.new(key, ssl_key_password)
            set :SSLCertificate, OpenSSL::X509::Certificate.new(cert)
            set :SSLCertName, [['CN', cert_name]]
          when :thin
            true
          end # case
        end # if ssl
      end # configure
    end # chook_configure

    def self.ssl_key_password
      path = Chook::CONFIG.ssl_private_key_pw_path
      raise 'No config setting for "ssl_private_key_pw_path"' unless path
      file = Pathname.new path

      # if the path ends with a pipe, its a command that will
      # return the desired password, so remove the pipe,
      # execute it, and return stdout from it.
      if path.end_with? '|'
        raise 'ssl_private_key_pw_path: #{path} is not an executable file.' unless file.executable?
        return `#{path.chomp '|'}`.chomp
      end

      raise 'ssl_private_key_pw_path: #{path} is not a readable file.' unless file.readable?
      stat = file.stat
      raise "Password file for '#{pw}' has insecure permissions, must be 0600." unless ('%o' % stat.mode).end_with? '0600'

      # chomping an empty string removes all trailing \n's and \r\n's
      file.read.chomp('')
    end # ssl_key_password

  end # class server

end # module

require 'chook/server/routes'
