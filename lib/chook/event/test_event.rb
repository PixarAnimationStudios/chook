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

#
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

    # For each event type in Chook::Event::EVENTS.keys
    # generate a TestEvent class for it, set its SUBJECT_CLASS constant
    # and add it to the TestEvents module.
    #
    # @return [void]
    #
    def self.generate_classes
      Chook::Event::EVENTS.each do |class_name, subject|
        next if Chook::TestEvent.const_defined? class_name

        # make the new TestEvent subclass
        the_class = Class.new(Chook::TestEvents)

        # Set its EVENT_NAME constant
        the_class.const_set Chook::TestEvent::EVENT_NAME_CONST, class_name

        # Set its SUBJECT_CLASS constant to the appropriate
        # class in the TestEvents module.
        the_class.const_set Chook::TestEvent::SUBJECT_CLASS_CONST, Chook::TestSubject.const_get(subject)

        # Add the new class to the HandledEvents module.
        Chook::TestEvents.const_set(class_name, the_class)
      end # each classname, subject
    end # self.generate_classes

    # define @classes reader in here???

  end # class TestEvent

end # module
