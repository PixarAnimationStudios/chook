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

  # the server
  class Server < Sinatra::Base

    # helper module for authentication
    module Auth

      USE_JAMF_ADMIN_USER = 'use_jamf'.freeze

      def protect_via_basic_auth!
        # don't protect if user isn't defined
        return unless Chook.config.webhooks_user
        return if webhook_user_authorized?
        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401, "Not authorized\n"
      end

      def webhook_user_authorized?
        @auth ||= Rack::Auth::Basic::Request.new(request.env)

        # gotta have basic auth presented to us
        unless @auth.provided? && @auth.basic? && @auth.credentials
          Chook.logger.debug "No basic auth provided on protected route: #{request.path_info} from: #{request.ip}"
          return false
        end

        authenticate_webhooks_user @auth.credentials
      end # authorized?

      # webhook user auth always comes from config
      def authenticate_webhooks_user(creds)
        if creds.first == Chook.config.webhooks_user && creds.last == Chook::Server.webhooks_user_pw
          Chook.logger.debug "Got HTTP Basic auth for webhooks user: #{Chook.config.webhooks_user}@#{request.ip}"
          true
        else
          Chook.logger.error "FAILED auth for webhooks user: #{Chook.config.webhooks_user}@#{request.ip}"
          false
        end
      end # authenticate_webhooks_user

      # admin user auth might come from config, might come from Jamf Pro
      def authenticate_admin(user, pw)
        return authenticate_jamf_admin(user, pw) if Chook.config.admin_user == USE_JAMF_ADMIN_USER
        authenticate_admin_user(user, pw)
      end

      # admin auth from config
      def authenticate_admin_user(user, pw)
        if user == Chook.config.admin_user && pw == Chook::Server.admin_user_pw
          Chook.logger.debug "Got auth for admin user: #{user}@#{request.ip}"
          session[:authed_admin] = user
          true
        else
          Chook.logger.warn "FAILED auth for admin user: #{user}@#{request.ip}"
          session[:authed_admin] = nil
          false
        end
      end

      # admin auth from jamf pro
      def authenticate_jamf_admin(user, pw)
        require 'ruby-jss'
        JSS::APIConnection.new(
          user: user,
          pw: pw,
          server: Chook.config.jamf_server,
          port: Chook.config.jamf_port,
          use_ssl: Chook.config.jamf_use_ssl,
          verify_cert: Chook.config.jamf_verify_cert
        )
        Chook.logger.debug "Jamf Admin login for: #{user}@#{request.ip}"

        session[:authed_admin] = user
        true
      rescue JSS::AuthenticationError
        Chook.logger.warn "Jamf Admin login FAILED for: #{user}@#{request.ip}"
        session[:authed_admin] = nil
        false
      end # authenticate_jamf_admin

    end # module auth

    helpers Chook::Server::Auth

    # Learn the webhook or admin passwords from config.
    # so we can authenticate them from the browser and the JSS
    #
    # This is at the Server level, since we only need read it
    # once per server startup, so we store it in a server
    # instance var.
    ###################################
    def self.webhooks_user_pw
      @webhooks_user_pw ||= pw_from_conf Chook.config.webhooks_user_pw
    end # self.webhooks_user_pw

    def self.admin_user_pw
      @admin_user_pw ||= pw_from_conf Chook.config.admin_pw
    end

    def self.pw_from_conf(setting)
      return '' unless setting

      # if the path ends with a pipe, its a command that will
      # return the desired password, so remove the pipe,
      # execute it, and return stdout from it.
      return pw_from_command(setting) if setting.end_with? '|'

      # otherwise its a file path, and read the pw from the contents
      pw_from_file(setting)
    end # def pw_from_conf(setting)

    def self.pw_from_command(cmd)
      cmd = cmd.chomp '|'
      output = `#{cmd} 2>&1`.chomp
      raise "Can't get password from #{cmd}: #{output}" unless $CHILD_STATUS.exitstatus.zero?
      output
    end

    def self.pw_from_file(file)
      file = Pathname.new file
      return nil unless file.file?
      stat = file.stat
      mode = format('%o', stat.mode)
      raise "Password file #{setting} has insecure mode, must be 0600." unless mode.end_with?('0600')
      raise "Password file #{setting} has insecure owner, must be owned by UID #{Process.euid}." unless stat.owned?
      # chomping an empty string removes all trailing \n's and \r\n's
      file.read.chomp('')
    end


  end # server

end # Chook

require 'chook/server/routes/home'
require 'chook/server/routes/handle_webhook_event'
require 'chook/server/routes/handlers'
require 'chook/server/routes/log'
