# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Chook

  # A subject that will be used within a HandledEvent class, to be received by
  # a Webhook server and processed.
  #
  # This is the parent class to all classes in the Chook::HandledSubjects module.
  #
  # All constants, methods, and attributes that are common to HandledSubject
  # classes are defined here.
  #
  class HandledSubject < Chook::Subject

    def self.generate_classes
      Chook::Subject.classes.each do |classname, attribs|
        # Don't redefine anything.
        next if Chook::HandledSubjects.const_defined? classname

        # new subclass of Chook::HandledSubject
        new_class = Class.new(Chook::HandledSubject) do
          # add getters for all the attributes.
          # no need for setters, as handled objects are immutable
          attribs.keys.each { |attrib| attr_reader attrib }
        end

        # set a class constant so each class knows it's name
        new_class.const_set Chook::Subject::NAME_CONSTANT, classname

        # add the class to the Chook::HandledSubjects namespace module
        Chook::HandledSubjects.const_set classname, new_class
      end # classes.each do |classname, attribs|
    end # generate_classes

    # All the subclassses will inherit this constructor
    #
    # The argument is a Hash, the parsed 'event_object' data
    # from the JSON blob for a webhook.
    #
    def initialize(subject_data_from_json)
      my_classname = self.class.const_get Chook::Subject::NAME_CONSTANT
      my_attribs = Chook::Subject.classes[my_classname]

      subject_data_from_json.each do |key, value|
        # ignore unknown attributes. Shouldn't get any,but....
        next unless my_attribs[key]

        # does the value need conversion?
        converter = my_attribs[key][:converter]
        if converter
          value = converter.is_a?(Symbol) ? value.send(converter) : converter.call(value)
        end # if converter

        # set the value.
        instance_variable_set "@#{key}", value
      end # each key value
    end # init

  end # class handled subject

end # module
