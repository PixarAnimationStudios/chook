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
    get '/reload_handlers' do
      logger.info 'Reloading handlers'
      Chook::HandledEvent::Handlers.load_handlers reload: true
      'Handlers reloaded'
    end # get /

    # used by javascript to fetch the content of a handler file
    get '/handler_code' do
      file = Pathname.new params[:filepath]

      # only if its a known handler path
      if Chook::HandledEvent::Handlers.all_handler_paths.include?(file) && file.file?
        body file.read
      else
        404
      end
    end

  end # class

end # module
