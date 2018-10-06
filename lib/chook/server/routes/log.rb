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

    # Body must be a JSON object (Hash) wth 2 keys 'level' and 'message'
    # where both values are strings
    post '/log' do
      request.body.rewind # in case someone already read it
      raw = request.body.read
      begin
        entry = JSON.parse raw, symbolize_names: true
        raise if entry[:level].to_s.empty? || entry[:message].to_s.empty?
      rescue
        msg = "Malformed log entry JSON: #{raw}"
        Chook::Server::Log.logger.error msg
        halt 409, msg
      end
      level = Chook::Server::Log::LOG_LEVELS[entry[:level].to_sym]
      level ||= Logger::UNKNOWN
      Chook::Server::Log.logger.send level, entry[:message]
      { result: "logged, level: #{level}" }.to_json
    end # post /

  end # class

end # module
