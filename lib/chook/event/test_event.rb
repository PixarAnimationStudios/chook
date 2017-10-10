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

  # An event that will be sent to a Webhook Server, simulating
  # one from the JSS.
  #
  # This is the parent class to all of the classes in the
  # Chook::TestEvents module, which are dynamically defined when this
  # file is loaded.
  #
  # All constants, methods, and attributes that are common to TestEvent
  # classes are defined here.
  #
  class TestEvent < Chook::Event

    EVENT_ATTRIBUTES = %w(webhook_id webhook_name subject).freeze

    # For each event type in Chook::Event::EVENTS.keys
    # generate a TestEvent class for it, set its SUBJECT_CLASS constant
    # and add it to the TestEvents module.
    #
    # @return [void]
    #
    def self.generate_classes
      Chook::Event::EVENTS.each do |classname, subject|
        next if Chook::TestEvents.const_defined? classname
        # make the new TestEvent subclass
        new_class = Class.new(Chook::TestEvent) do
          # Setters & Getters
          EVENT_ATTRIBUTES.each do |attribute|
            # Getter
            attr_reader attribute
            # Setter
            if attribute == 'subject'
              define_method("#{attribute}=") do |new_val|
                raise "Invalid TestSubject: Chook::TestEvents::#{classname} requires a Chook::TestSubjects::#{EVENTS[classname]}" unless Chook::Validators.send(:valid_test_subject, classname, new_val)
                instance_variable_set(('@' + attribute.to_s), new_val)
              end # end define_method
            else
              define_method("#{attribute}=") do |new_val|
                instance_variable_set(('@' + attribute.to_s), new_val)
              end # end define_method
            end
          end # end EVENT_ATTRIBUTES.each do |attribute|
        end # end new_class

        # Set its EVENT_NAME constant
        new_class.const_set Chook::TestEvent::EVENT_NAME_CONST, classname

        # Set its SUBJECT_CLASS constant to the appropriate
        # class in the TestEvents module.
        new_class.const_set Chook::TestEvent::SUBJECT_CLASS_CONST, Chook::TestSubjects.const_get(subject)

        # Add the new class to the HandledEvents module.
        Chook::TestEvents.const_set(classname, new_class)
      end # each classname, subject
    end # self.generate_classes

    # json_hash
    #
    # @return [Hash] A JSON Event payload formatted as a Hash. Used by the fire method
    #
    def json_hash
      raw_hash_form = {}
      raw_hash_form['webhook'.to_sym] = { 'webhookEvent'.to_sym => self.class.to_s.split('::')[-1] }
      EVENT_ATTRIBUTES.each do |json_attribute|
        next if json_attribute.include? 'json'
        if json_attribute == 'subject'
          raw_hash_form['event'.to_sym] = instance_variable_get('@' + json_attribute).json_hash
        else
          json_hash_attribute = json_attribute.split('webhook_')[1] || json_attribute
          nested_hash = Hash.new do |hash, key|
            hash[key] = {}
          end # end nested_hash
          nested_hash[json_hash_attribute.to_sym] = instance_variable_get('@' + json_attribute)
          raw_hash_form['webhook'.to_sym][nested_hash.keys[0]] = nested_hash[nested_hash.keys[0]]
        end
      end # end EVENT_ATTRIBUTES.each do |json_attribute|
      raw_hash_form # This is the structural equivalent of the Chook::Event @json_hash form
    end # end json_hash

    # fire
    #
    # @param [String] server_url The URL of a server that can handle an Event
    # @return [void]
    #
    def fire(server_url)
      raise 'Please provide a destination server URL' unless server_url
      uri = URI.parse(server_url)
      raise 'Please provide a valid destination server URL' if uri.host.nil?
      data = json_hash.to_json # This is the structural equivalent of the Chook::Event @raw_json form
      http_connection = Net::HTTP.new uri.host, uri.port
      http_connection.post(uri, data)
    end # end fire

    def initialize(event_data = nil)
      if event_data
        event_data.each do |key, value|
          next unless EVENT_ATTRIBUTES.include? key
          instance_variable_set(('@' + key.to_s), value)
        end # event_data.each
      else
        EVENT_ATTRIBUTES.each { |attribute| instance_variable_set(('@' + attribute.to_s), nil) }
      end # end if event_data
    end # end init

  end # class TestEvent

end # module
