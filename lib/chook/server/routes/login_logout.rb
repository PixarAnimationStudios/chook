# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Chook

  # see server.rb
  class Server < Sinatra::Base

    # reload the handlers
    get '/logout' do
      session[:authed_admin] = nil
      session[:auth_failed] = nil
      redirect '/'
    end # get /

    # reload the handlers
    post '/login' do
      Chook.logger.debug "Attempting to log in #{params[:username]}"
      session[:auth_failed] = !authenticate_admin(params[:username], params[:password])
      redirect '/'
    end # get /

  end # class

end # module
