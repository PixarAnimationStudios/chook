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

  # A subject that will be used with a TestEvent class, to be sent to
  # a Webhook server, simulating one from the JSS.
  #
  # This is the parent class to all classes in the Chook::TestSubjects module.
  #
  # All constants, methods, and attributes that are common to TestSubject
  # classes are defined here.
  #
  class TestSubject < Chook::Subject

    # Dynamically generate the varios subclasses to TestSubject
    # and store them in the TestSubjects module.
    def self.generate_classes
      Chook::Subject.classes.each do |classname, attribs|
        # Don't redefine anything.
        next if Chook::TestSubjects.const_defined? classname

        # new subclass of Chook::TestSubject
        new_class = Class.new(Chook::TestSubject) do
          # add getter, setters, validators for all the attribs.
          attribs.each do |attrib, deets|
            # getter
            attr_reader attrib
            validator = deets[:validation]

            # setter with validator
            define_method("#{attrib}=") do |new_val|
              if validator.is_a? Class
                raise "Invalid value for #{attrib}, must be a #{validator}"
              elsif !validator.nil?
                raise "Invalid value for #{attrib}" unless Chook::Validators.send validator, new_val
              end
              instance_variable_set attrib, new_val
            end # end define method
          end # end do |attrib, deets|
        end # end new_class
        # set a class constant so each class knows it's name
        new_class.const_set Chook::Subject::NAME_CONSTANT, classname

        # add the class to the Chook::TestSubjects module
        Chook::TestSubjects.const_set classname, new_class
      end # end Chook::Subject.classes.each do |classname, attribs|
    end # end generate_classes

    # a random test subject,
    def self.random
      random_vals = {}
      Chook::Subject.classes[].each do |attrib, deets|
        random_vals[attrib] = Chook::Randomizers.send deets[:randomizer]
      end # each do |attr_def|
      new random_vals
    end # end random

    # a sampled test subject (real data from real JSS objects)
    # NOTE: a valid ruby-jss JSS::APIConnection must exist
    def self.sample(ids = 'random', api: JSS.api)
      # Placeholder
    end # end sample

    # All the subclassses will inherit this constructor
    #
    # The argument is a Hash with keys from the appropriate keys defiend
    # in Chook::Subject.classes
    #
    def initialize(subject_data)
      my_classname = self.class.const_get Chook::Subject::NAME_CONSTANT
      my_attribs = Chook::Subject.classes[my_classname]

      subject_data.each do |key, value|
        # ignore unknown attributes. Shouldn't get any,but....
        next unless my_attribs[key]

        # does the value need conversion?
        converter = my_attribs[key][:converter]
        if converter
          value = converter.is_a?(Symbol) ? value.send(converter) : converter.call(value)
        end # if converter

        # set the value.
        instance_variable_set ":@#{key}", value
      end # each key value
    end # init

  end # class TestSubject

end # module
