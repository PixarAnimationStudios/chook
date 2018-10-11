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

    get '/' do
      protected!

      # a list of current handlers for the admin page
      @handlers_for_admin_page = []

      Chook::HandledEvent::Handlers.handlers.keys.sort.each do |eventname|
        Chook::HandledEvent::Handlers.handlers[eventname].each do |handler|
          if handler.is_a? Pathname
            file = handler
            type = :external
          else
            file = Pathname.new(Chook.config.handler_dir) + handler.handler_file
            type = :internal
          end # if else
          @handlers_for_admin_page << { event: eventname, file: file, type: type }
        end # handlers each
      end # Handlers.handlers.each

      # the current config, for the admin page
      @config_text =
        if Chook::Configuration::DEFAULT_CONF_FILE.file?
          @config_src = Chook::Configuration::DEFAULT_CONF_FILE.to_s
          Chook::Configuration::DEFAULT_CONF_FILE.read

        elsif Chook::Configuration::SAMPLE_CONF_FILE.file?
          @config_src = "Using default values, showing sample config file at #{Chook::Configuration::SAMPLE_CONF_FILE}"
          Chook::Configuration::SAMPLE_CONF_FILE.read

        else
          @config_src = "No #{Chook::Configuration::DEFAULT_CONF_FILE} or sample config file found."
          @config_src
        end

      haml :admin
    end # get /

  end # class

end # module
