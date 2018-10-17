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

    # External Handlers can use this route to make log entries.
    #
    # The request body must be a JSON object (Hash) wth 2 keys 'level' and 'message'
    # where both values are strings
    #
    # Here's an example with curl, split to multi-line for clarity:
    #
    # curl -H "Content-Type: application/json" \
    #   -X POST \
    #   --data '{"level":"debug", "message":"It Worked"}' \
    #   https://user:passwd@chookserver.myorg.org:443/log
    #
    post '/log' do
      protected!
      request.body.rewind # in case someone already read it
      raw = request.body.read

      begin
        logentry = JSON.parse raw, symbolize_names: true
        raise if logentry[:level].to_s.empty? || logentry[:message].to_s.empty?
      rescue
        Chook::Server::Log.logger.error "Malformed log entry JSON from #{request.ip}: #{raw}"
        halt 409, "Malformed log entry JSON: #{raw}"
      end

      level = logentry[:level].to_sym
      level = :unknown unless Chook::Server::Log::LOG_LEVELS.key? level
      Chook::Server::Log.logger.send level, "ExternalEntry: #{logentry[:message]}"

      { result: 'logged', level: level }.to_json
    end # post /

    # AJAXy access to a log stream
    # When an admin displays the log on the chook admin/home page,
    # the page's javascript starts the stream as an EventSource
    # from this url.
    #
    # The innards are taken almost verbatim from the Sinatra README
    # docs.
    #
    # See also logstream.js and views/admin.haml
    #
    #
    get '/subscribe_to_log_stream', provides: 'text/event-stream' do
      protected!
      content_type 'text/event-stream'
      cache_control 'no-cache'

      # register a client's interest in server events
      stream(:keep_open) do |outbound_stream|
        # add this connection to the array of streams
        Chook::Server::Log.log_streams[outbound_stream] = request.ip
        logger.debug "Added log stream for #{request.ip}"
        # purge dead connections
        Chook::Server::Log.clean_log_streams
      end # stream
    end

    # set the log level via the admin page.
    put '/set_log_level/:level' do
      protected!
      level = params[:level].to_sym
      level = :unknown unless Chook::Server::Log::LOG_LEVELS.key? level
      Chook.logger.level = level
      Chook.logger.unknown "Log level changed, now: #{level}"
      { result: 'level changed', level: level }.to_json
    end

    # get the log level via the admin page.
    get '/current_log_level' do
      protected!
      Chook::Server::Log::LOG_LEVELS.invert[Chook.logger.level].to_s
    end

  end # class

end # module
