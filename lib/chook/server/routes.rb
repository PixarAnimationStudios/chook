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

    # These two helpers let us decude which routes need
    # http basic auth and which don't
    #
    # To protect a route, put `protected!` as the
    # first line of code in the route.
    #
    # See http://sinatrarb.com/faq.html#auth
    #
    helpers do
      def protected!
        # don't protect if user isn't defined
        return unless Chook.config.webhooks_user
        return if authorized?
        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401, "Not authorized\n"
      end

      def authorized?
        @auth ||= Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && \
          @auth.basic? && \
          @auth.credentials && \
          @auth.credentials == [Chook.config.webhooks_user, Chook::Server.webhooks_user_pw]
      end
    end

    # log errors in production (in dev, they go to stdout and the browser)
    error do
      logger.error "ERROR: #{env['sinatra.error'].message}"
      env['sinatra.error'].backtrace.each { |l| logger.error "..#{l}" }
      500
    end

  end # server

end # Chook

require 'chook/server/routes/home'
require 'chook/server/routes/handle_webhook_event'
require 'chook/server/routes/reload_handlers'
require 'chook/server/routes/log'
