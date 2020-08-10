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

  # see server.rb
  class Server < Sinatra::Base

    post '/handler/:handler_name' do
      # enforce http basic auth if needed
      protect_via_basic_auth!

      # rewind to ensure read-pointer is at the start
      request.body.rewind #
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
