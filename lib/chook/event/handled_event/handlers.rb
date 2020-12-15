# Copyright 2017 Pixar
#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
#
#

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
    Chook.logger.debug "Code block for 'Chook.event_handler' loaded into \#handle method of runner-object #{obj.object_id}"
  end

  # the server class
  class HandledEvent < Event

    # The Handlers namespace module
    module Handlers

      # Don't load any handlers whose filenames start with this
      DO_NOT_LOAD_PREFIX = 'Ignore-'.freeze

      DEFAULT_HANDLER_DIR = '/Library/Application Support/Chook'.freeze

      # Handlers that are only called by name using the route:
      #     post '/handler/:handler_name'
      # are located in this subdirection of the handler directory
      NAMED_HANDLER_SUBDIR = 'NamedHandlers'.freeze

      # internal handler files must match this regex somewhere
      INTERNAL_HANDLER_BLOCK_START_RE = /Chook.event_handler( ?\{| do) *\|/

      # self loaded_handler=
      #
      # @return [Obj,nil] the most recent Proc loaded from a handler file.
      # destined for storage in @handlers
      #
      def self.loaded_handler
        @loaded_handler
      end

      # A holding place for internal handlers as they are loaded
      # before being added to the @handlers Hash
      # see Chook.event_handler(&block)
      #
      # @param a_proc [Object]  An object instance with a #handle method
      #
      def self.loaded_handler=(anon_obj)
        @loaded_handler = anon_obj
      end

      # Getter for @handlers
      #
      # @return [Hash{String => Array}] a mapping of Event Names as they
      # come from the JSS to an Array of handlers for the event.
      # The handlers are either Pathnames to executable external handlers
      # or Objcts with a #handle method, for internal handlers
      #  (The objects also have a #handler_file attribute that is the Pathname)
      #
      def self.handlers
        @handlers ||= {}
      end

      # Handlers can check Chook::HandledEvent::Handlers.reloading?
      # and do stuff if desired.
      def self.reloading?
        @reloading
      end

      # getter for @named_handlers
      # These handlers are called by name via the route
      # " post '/handler/:handler_name'"
      #
      # They are not tied to any event type by their filenames
      # its up to the writers of the handlers to make sure
      # the webhook that calls them is sending the correct event
      # type.
      #
      # The data structure of @named_handlers is a
      # Hash of Strings to Pathnames or Anon Objects:
      # {
      #     handler_filename => Pathname or Obj,
      #     handler_filename => Pathname or Obj,
      #     handler_filename => Pathname or Obj
      # }
      #
      # @return [Hash {String => Pathname, Proc}]
      def self.named_handlers
        @named_handlers ||= {}
      end

      # the Pathname objects for all loaded handlers
      #
      # @return [Array<Pathname>]
      #
      def self.all_handler_paths
        hndlrs = named_handlers.values
        hndlrs += handlers.values.flatten
        hndlrs.map do |hndlr|
          hndlr.is_a?(Pathname) ? hndlr : hndlr.handler_file
        end
      end

      # Load all the event handlers from the handler_dir or an arbitrary dir.
      #
      #
      # Handler files must be either:
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
        # use default if needed
        from_dir ||= DEFAULT_HANDLER_DIR
        handler_dir = Pathname.new(from_dir)
        named_handler_dir = handler_dir + NAMED_HANDLER_SUBDIR
        load_type = 'Loading'

        if reload
          @reloading = true
          @handlers = {}
          @named_handlers = {}
          @loaded_handler = nil
          load_type = 'Re-loading'
        end

        # General Handlers
        Chook.logger.info "#{load_type} general handlers from directory: #{handler_dir}"
        if handler_dir.directory? && handler_dir.readable?
          handler_dir.children.each do |handler_file|
            # ignore if marked to
            next if handler_file.basename.to_s.start_with? DO_NOT_LOAD_PREFIX

            load_general_handler(handler_file) if handler_file.file? && handler_file.readable?
          end
          Chook.logger.info handlers.empty? ? 'No general handlers found' : "Loaded #{handlers.values.flatten.size} general handlers for #{handlers.keys.size} event triggers"
        else
          Chook.logger.error "General handler directory '#{from_dir}' not a readable directory. No general handlers loaded. "
        end

        # Named Handlers
        Chook.logger.info "#{load_type} named handlers from directory: #{named_handler_dir}"
        if named_handler_dir.directory? && named_handler_dir.readable?
          named_handler_dir.children.each do |handler_file|
            # ignore if marked to
            next if handler_file.basename.to_s.start_with? DO_NOT_LOAD_PREFIX

            load_named_handler(handler_file) if handler_file.file? && handler_file.readable?
          end
          Chook.logger.info "Loaded #{named_handlers.size} named handlers"
        else
          Chook.logger.error "Named handler directory '#{named_handler_dir}' not a readable directory. No named handlers loaded. "
        end

        @reloading = false
      end # load handlers

      # Load a general event handler from a file.
      #
      # General Handler files must begin with the name of the event they handle,
      # e.g. ComputerAdded,  followed by: nothing, a dot, a dash, or
      # and underscore. Case doesn't matter.
      # So all of these are OK:
      # ComputerAdded
      # computeradded.sh
      # COMPUTERAdded_notify_team
      # Computeradded-update-ldap
      # There can be as many as desired for each event.
      #
      # @param handler_file [Pathname] the file from which to load the handler
      #
      # @return [void]
      #
      def self.load_general_handler(handler_file)
        Chook.logger.debug "Starting load of general handler file '#{handler_file.basename}'"

        event_name = event_name_from_handler_filename(handler_file)
        unless event_name
          Chook.logger.debug "Ignoring general handler file '#{handler_file.basename}': Filename doesn't start with event name"
          return
        end

        # create an array for this event's handlers, if needed
        handlers[event_name] ||= []

        # external? if so, its executable and we only care about its pathname
        if handler_file.executable?
          Chook.logger.info "Loading external general handler file '#{handler_file.basename}' for #{event_name} events"
          handlers[event_name] << handler_file
          return
        end

        # Internal, we store an object with a .handle method
        Chook.logger.info "Loading internal general handler file '#{handler_file.basename}' for #{event_name} events"
        load_internal_handler handler_file
        handlers[event_name] << @loaded_handler if @loaded_handler

      end # self.load_general_handler(handler_file)

      # Load a named event handler from a file.
      #
      # Named Handler files can have any name, as they are called directly
      # from a Jamf webhook via URL.
      #
      # @param handler_file [Pathname] the file from which to load the handler
      #
      # @return [void]
      #
      def self.load_named_handler(handler_file)
        Chook.logger.debug "Starting load of named handler file '#{handler_file.basename}'"

        # external? if so, its executable and we only care about its pathname
        if handler_file.executable?
          Chook.logger.info "Loading external named handler file '#{handler_file.basename}'"
          named_handlers[handler_file.basename.to_s] = handler_file
          return
        end

        # Internal, we store an object with a .handle method
        Chook.logger.info "Loading internal named handler file '#{handler_file.basename}'"
        load_internal_handler handler_file
        named_handlers[handler_file.basename.to_s] = @loaded_handler if @loaded_handler
      end # self.load_general_handler(handler_file)

      # if the given file is executable, store it's path as a handler for the event
      #
      # @return [Boolean] did we load an external handler?
      #
      def self.load_external_handler(handler_file, event_name, named)
        return false unless handler_file.executable?

        say_named = named ? 'named ' : ''
        Chook.logger.info "Loading #{say_named}external handler file '#{handler_file.basename}' for #{event_name} events"

        if named
          named_handlers[event_name][handler_file.basename.to_s] = handler_file
        else
          # store the Pathname, we'll pipe JSON to it
          handlers[event_name] << handler_file
        end

        true
      end

      # if a given path is not executable, try to load it as an internal handler
      #
      # @param handler_file[Pathname] the handler file
      #
      # @return [Object] and anonymous object that has a .handle method
      #
      def self.load_internal_handler(handler_file)
        # load the file. If written correctly, it will
        # put an anon. Object with a #handle method into @loaded_handler
        unless handler_file.read =~ INTERNAL_HANDLER_BLOCK_START_RE
          Chook.logger.error "Internal handler file '#{handler_file}' missing event_handler block"
          return nil
        end

        # reset @loaded_handler - the `load` call will refill it
        # see Chook.event_handler
        @loaded_handler = nil

        begin
          load handler_file.to_s
          raise '@loaded handler nil after loading file' unless @loaded_handler
        rescue => e
          Chook.logger.error "FAILED loading internal handler file '#{handler_file}': #{e}"
          return
        end

        # add a method to the object to get its Pathname
        @loaded_handler.define_singleton_method(:handler_file) { handler_file }

        # return it
        @loaded_handler
      end

      # Given a handler filename, return the event name it wants to handle
      #
      # @param [Pathname] filename The filename from which to glean the
      #   event name.
      #
      # @return [String,nil] The matching event name or nil if no match
      #
      def self.event_name_from_handler_filename(filename)
        filename = filename.basename
        @event_names ||= Chook::Event::EVENTS.keys
        desired_event_name = filename.to_s.split(/\.|-|_/).first
        ename = @event_names.select { |n| desired_event_name.casecmp(n).zero? }.first
        if ename
          Chook.logger.debug "Found event name '#{ename}' at start of filename '#{filename}'"
        else
          Chook.logger.debug "No known event name at start of filename '#{filename}'"
        end
        ename
      end

    end # module Handler

  end # class handledevent

end # module
