# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Chook

  # the server
  class Server < Sinatra::Base

    HANDLE_EVENT_ROUTE = '/handle_webhook_event'.freeze

    #   before do
    #     break if request.path_info == Chook::Server::HANDLE_EVENT_ROUTE
    # #    break if request.path_info == '/' && session[:authed_admin]
    # #    redirect '/' unless session[:authed_admin]
    #   end

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
require 'chook/server/routes/handle_by_name'
require 'chook/server/routes/handlers'
require 'chook/server/routes/login_logout'
require 'chook/server/routes/log'
