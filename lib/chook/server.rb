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

module Chook

  # The chook server is a basic sinatra server running on
  # the engine of your choice.
  class Server < Sinatra::Base

    DEFAULT_SERVER_ENGINE = :webrick
    DEFAULT_PORT = 8000

    # Sinatra Settings
    configure do
      server_engine = Chook::CONFIG.server_engine || DEFAULT_SERVER_ENGINE
      server_port = Chook::CONFIG.server_port || DEFAULT_PORT
      enable :logging, :lock
      set :bind, '0.0.0.0'
      set :server, server_engine
      set :port, server_port
    end # configure

  end # class server

end # module

require 'chook/server/routes'
