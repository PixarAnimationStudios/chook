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

require 'chook/event/handled_event/handlers'

#
module Chook

  # An event that has been recieved and needs to be handled.
  #
  # This is the parent class to all of the classes in the
  # Chook::HandledEvents module, which are dynamically defined when this
  # file is loaded.
  #
  # All constants, methods, and attributes that are common to HandledEvent
  # classes are defined here, including the interaction with the Handlers
  # module.
  #
  # Subclasses are automatically generated from the keys and values of
  # Chook::Event::EVENTS
  #
  # Each subclass will have a constant SUBJECT_CLASS containing the
  # class of their #subject attribute.
  #
  class HandledEvent < Chook::Event

    #### Class Methods

    # Given some raw_json from the jss, create and return the correct
    # HandledEvent subclass

    # For each event type in Chook::Event::EVENTS
    # generate a class for it, set its SUBJECT_CLASS constant
    # and add it to the HandledEvents module.
    #
    # @return [void]
    #
    def self.generate_classes
      Chook::Event::EVENTS.each do |class_name, subject|
        next if Chook::HandledEvents.const_defined? class_name

        # make the new HandledEvent subclass
        the_class = Class.new(Chook::HandledEvent)


        # Set its EVENT_NAME constant, which is used
        # for finding it's handlers, among other things.
        the_class.const_set Chook::Event::EVENT_NAME_CONST, class_name

        # Set its SUBJECT_CLASS constant to the appropriate
        # class in the HandledSubjects module.
        the_class.const_set Chook::Event::SUBJECT_CLASS_CONST, Chook::HandledSubjects.const_get(subject)

        # Add the new class to the HandledEvents module.
        Chook::HandledEvents.const_set(class_name, the_class)
      end # each classname, subject
    end # self.generate_classes


    # Given the raw json from the JSS webhook,
    # create an object of the correct Event subclass
    #
    # @param [String] raw_event_json The JSON http POST content from the JSS
    #
    # @return [JSSWebHooks::Event subclass] the Event subclass matching the event
    #
    def self.parse_event(raw_event_json)
      event_json = JSON.parse(raw_event_json, symbolize_names: true)
      event_name = event_json[:webhook][:webhookEvent]
      Chook::HandledEvents.const_get(event_name).new raw_event_json
    end


    #### Attributes

    # @return [Array<Proc,Pathname>] the handlers defined for this event.
    #   Each is either a proc, in which case it is called with this
    #   instance as its sole paramter, or its a Pathname to an executable
    #   file, in which case the @raw_json is passed to its stdin.
    #   See the Chook::HandledEvent::Handlers module.
    attr_reader :handlers

    #### Constructor

    # Handled Events are always built from raw_json.
    #
    def initialize(raw_event_json)
      super raw_json: raw_event_json
    end # init

    def handle
      handlers = Handlers.handlers[self.class.const_get(Chook::Event::EVENT_NAME_CONST)]
      handlers.each do |handler|
        case handler
        when Pathname
          pipe_to_executable handler
        when Proc
          handle_with_proc handler
        end # case
      end # @handlers.each do |handler|

      # the handle method should return a string,
      # which is the body of the HTTP result for
      # POSTing the event
      "Processed by #{handlers.count} handlers\n"
    end # def handle

    # TODO: have something here that
    # cleans up old threads and forks
    def pipe_to_executable(handler)
      _thread = Thread.new do
        IO.popen([handler.to_s], 'w') { |h| h.puts @raw_json }
      end
    end

    def handle_with_proc(handler)
      _thread = Thread.new { handler.call self }
    end

  end # class HandledEvent

end # module
