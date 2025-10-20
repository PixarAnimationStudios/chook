# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Chook

  # see server.rb
  class Server < Sinatra::Base

    post '/handler/:handler_name' do
      # enforce http basic auth if needed
      protect_via_basic_auth!

      # rewind to ensure read-pointer is at the start
      request.body.rewind
      raw_json = request.body.read

      event = Chook::HandledEvent.parse_event raw_json

      if event.nil?
        logger.error "Empty JSON from #{request.ip}"
        result = 400
      else

        event.logger.debug "START From #{request.ip}, WebHook '#{event.webhook_name}' (id: #{event.webhook_id})"
        event.logger.debug "Thread id: #{Thread.current.object_id}; JSON: #{raw_json}"

        result = event.handle_by_name params[:handler_name]

        event.logger.debug "END #{result}"
      end

      # this route shouldn't have a session expiration
      # And when it does, the date format is wrong, and the
      # JAMFSoftwareServerLog complains about it for every
      # webhook sent.
      env['rack.session.options'].delete :expire_after

      result
    end # post

  end # class

end # module
