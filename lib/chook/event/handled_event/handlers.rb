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

  # This method is used by the Ruby 'internal' event-handler files.
  #
  # those handlers are defined by passing a block to this method, like so:
  #
  #   Chook.event_handler do |event|
  #     # so something with the event
  #   end
  #
  # Loading them will call this method and pass in a block
  # with one parameter: a Chook::HandledEvent subclass instance.
  #
  # The block is then converted to a #handle method in an anonymous object.
  # The object is stored for use by the event identified by the filename.
  #
  # By storing it as a method in an object, the handlers themselves
  # can use #break or #return to exit (or even #next)
  #
  # NOTE: the files should be read with 'load' not 'require', so that they can
  # be re-loaded as needed
  #
  # @see_also Chook::load_handlers
  #
  # @param [Block] block the block to be used as an event handler
  #
  # @yieldparam [JSS::WebHooks::Event subclass] The event to be handled
  #
  # @return [Proc] the block converted to a Proc
  #
  def self.event_handler(&block)
    obj = Object.new
    obj.define_singleton_method(:handle, &block)
    # Loading the file created the object by calling this method
    # but to access it after loading the file, we need to
    # store it in here:
    HandledEvent::Handlers.loaded_handler = obj
  end

  # the server class
  class HandledEvent < Event

    # The Handlers namespace module
    module Handlers

      # Module Constants
      ############################

      DEFAULT_HANDLER_DIR = '/Library/Application Support/Chook'.freeze

      # Module Instance Variables, & accessors
      ############################

      # This holds the most recently loaded Proc handler
      # until it can be stored in the @handlers Hash
      @loaded_handler = nil

      # Getter for @loaded_handler
      #
      # @return [Proc,nil] the most recent Proc loaded from a handler file.
      # destined for storage in @handlers
      #
      def self.loaded_handler
        @loaded_handler
      end

      # Setter for @loaded_event_handler
      #
      # @param a_proc [Object]  An object instance with a #handle method
      #
      def self.loaded_handler=(anon_obj)
        @loaded_handler = anon_obj
      end

      # A hash of loaded handlers.
      # Keys are Strings - the name of the events handled
      # Values are Arrays of either Procs, or Pathnames to executable files.
      # See the .handlers getter Methods
      @handlers = {}

      # Getter for @event_handlers
      #
      # @return [Hash{String => Array}] a mapping of Event Names as the come from
      # the JSS to an Array of handlers for the event. The handlers are either
      # Proc objects to call from within ruby, or Pathnames to executable files
      # which will take raw JSON on stdin.
      def self.handlers
        @handlers
      end

      # Module Methods
      ############################

      # Load all the event handlers from the handler_dir or an arbitrary dir.
      #
      # @param from_dir [String, Pathname] directory from which to load the
      #   handlers. Defaults to CONFIG.handler_dir or DEFAULT_HANDLER_DIR if
      #   config is unset
      #
      # @param reload [Boolean] should we reload handlers if they've already
      #   been loaded?
      #
      # @return [void]
      #
      def self.load_handlers(from_dir: Chook.config.handler_dir, reload: false)
        from_dir ||= DEFAULT_HANDLER_DIR
        if reload
          @handlers_loaded_from = nil
          @handlers = {}
          @loaded_handler = nil
        end

        handler_dir = Pathname.new(from_dir)
        unless handler_dir.directory? && handler_dir.readable?
          Chook.log.info "Handler directory '#{from_dir}' not a readable directory. No handlers loaded. "
          return
        end

        handler_dir.children.each do |handler_file|
          load_handler(handler_file) if handler_file.file? && handler_file.readable?
        end

        @handlers_loaded_from = handler_dir
        Chook.log.info "Loaded #{@handlers.values.flatten.size} handlers for #{@handlers.keys.size} event triggers"
      end # load handlers

      # Load an event handler from a file.
      # Handler files must begin with the name of the event they handle,
      # e.g. ComputerAdded,  followed by: nothing, a dot, a dash, or
      # and underscore. Case doesn't matter.
      # So all of these are OK:
      # ComputerAdded
      # computeradded.sh
      # COMPUTERAdded_notify_team
      # Computeradded-update-ldap
      # There can be as many as desired for each event.
      #
      # Each must be either:
      #   - An executable file, which will have the raw JSON from the JSS piped
      #     to it's stdin when executed
      # or
      #   - A non-executable file of ruby code like this:
      #     Chook.event_handler do |event|
      #       # your code goes here.
      #     end
      #
      # (see the Chook README for details about writing the ruby handlers)
      #
      # @param from_file [Pathname] the file from which to load the handler
      #
      # @return [void]
      #
      def self.load_handler(from_file)
        handler_file = Pathname.new from_file
        event_name = event_name_from_handler_filename(handler_file)
        return unless event_name

        # create an array for this event's handlers, if needed
        @handlers[event_name] ||= []

        if handler_file.executable?
          # store as a Pathname, we'll pipe JSON to it
          unless @handlers[event_name].include? handler_file
            @handlers[event_name] << handler_file
            Chook.log.info "Loaded executable handler file '#{handler_file.basename}' for #{event_name} events"
          end
          return
        end

        # load the file. If written correctly, it will
        # put n Object into @loaded_handler with a #handle method
        @loaded_handler = nil
        load handler_file.to_s
        if @loaded_handler
          @loaded_handler.define_singleton_method(:handler_file) { handler_file.basename.to_s }
          @handlers[event_name] << @loaded_handler
          Chook.log.info "Loaded internal handler file '#{handler_file.basename}' for #{event_name} events"
          @loaded_handler = nil
        else
          Chook.log.info "FAILED loading internal handler file '#{handler_file.basename}'"
        end
      end # self.load_handler(handler_file)

      # Given a handler filename, return the event name it wants to handle
      #
      # @param [Pathname] filename The filename from which to glean the
      #   event name.
      #
      # @return [String,nil] The matching event name or nil if no match
      #
      def self.event_name_from_handler_filename(filename)
        @event_names ||= Chook::Event::EVENTS.keys
        desired_event_name = filename.basename.to_s.split(/\.|-|_/).first
        @event_names.select { |n| desired_event_name.casecmp(n).zero? }.first
      end

    end # module Handler

  end # class handledevent

end # module
