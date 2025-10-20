# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Chook

  # see server.rb
  class Server < Sinatra::Base

    get '/' do
      # a list of current handlers for the admin page
      @handlers_for_admin_page = []

      Chook::HandledEvent::Handlers.handlers.keys.sort.each do |eventname|
        Chook::HandledEvent::Handlers.handlers[eventname].each do |handler|
          if handler.is_a? Pathname
            file = handler
            type = :external
          else
            file = handler.handler_file
            type = :internal
          end # if else
          @handlers_for_admin_page << { event: eventname, file: file, type: type }
        end # handlers each
      end # Handlers.handlers.each

      # a list of current named handlers for the admin page
      @named_handlers_for_admin_page = []

      Chook::HandledEvent::Handlers.named_handlers.each do |_name, handler|
        if handler.is_a? Pathname
          file = handler
          type = :external
        else
          file = handler.handler_file
          type = :internal
        end # if else
        @named_handlers_for_admin_page << { file: file, type: type }
      end # handlers each

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
