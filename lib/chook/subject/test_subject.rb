### Copyright 2025 Pixar

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
                raise "Invalid value for #{attrib}, must be a #{validator}" unless new_val.is_a? validator
              elsif !validator.nil?
                raise "Invalid value for #{attrib}" unless Chook::Validators.send validator, new_val
              end
              instance_variable_set(('@' + attrib.to_s), new_val)
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
      Chook::Subject.classes[const_get NAME_CONSTANT].each do |attrib, deets|
        random_vals[attrib] = Chook::Randomizers.send deets[:randomizer] if deets[:randomizer]
      end # each do |attr_def|
      new random_vals
    end # end random

    # a sampled test subject (real data from real JSS objects)
    # NOTE: a valid ruby-jss JSS::APIConnection must exist
    def self.sample(ids = 'random', api: JSS.api)
      classname = const_get Chook::Subject::NAME_CONSTANT
      ids = [ids] if ids.is_a? Integer
      # !!Kernel.const_get('JSS::' + classname) rescue false
      all_ids = if classname == 'PatchSoftwareTitleUpdated'
                  Chook::Samplers.all_patch_ids('blah', api: api)
                else
                  Kernel.const_get('JSS::' + classname).all_ids(api: api) # (api: api)
                end
      ids = [all_ids.sample] if ids == 'random'

      ok = true
      if ids.is_a? Array
        ids.each { |id| ok == false unless id.is_a? Integer }
      else
        ok = false
      end
      raise 'ids must be an Array of Integers' unless ok

      raw_samples = []
      samples = []

      valid_ids = ids & all_ids
      raise "Invalid JSS IDs: #{ids}" if valid_ids.empty?

      valid_ids.each do |id|
        if classname == 'PatchSoftwareTitleUpdated'
          raw_samples << Chook::Samplers.all_patches(api: api).select { |patch| patch[:id] == id }
          raw_samples.flatten!
        else
          raw_samples << Kernel.const_get('JSS::' + classname).fetch(id: id, api: api)
        end
      end

      raw_samples.each do |sample|
        subject_details = {}
        Chook::Subject.classes[classname].map do |subject_key, details|
          extractor = details[:api_object_attribute]
          subject_details[subject_key] =
            case extractor
            when Symbol
              if classname == 'PatchSoftwareTitleUpdated'
                # If there is a sampler method available, call it.
                if details[:sampler]
                  extractor = details[:sampler]
                  Chook::Samplers.send(extractor, sample)
                else
                  # Otherwise use it like a hash key
                  sample[extractor]
                end
              else
                sample.send extractor
              end
            when Array
              extractor = extractor.dup # If this doesn't get duplicated, shift will change details[:api_object_attribute]
              method = extractor.shift
              raw_hash_keys = extractor
              method_result = sample.send(method)
              raw_hash_keys.each { |key| method_result = method_result[key] }
              method_result
            when Proc
              extractor.call sample
            end
        end # do |subject_key, details|
        samples << Kernel.const_get('Chook::TestSubjects::' + classname).new(subject_details)
      end # end samples.each do |sample|
      samples
    end # end sample

    def json_hash
      # Verify that input is a child of TestSubjects, raise if not
      raise 'Invalid TestSubject' unless self.class.superclass == Chook::TestSubject

      test_subject_attributes = Chook::Subject.classes[self.class.to_s.split('::')[-1]]
      raw_hash_form = {}
      test_subject_attributes.each do |attribute, details|
        raw_hash_form[attribute] = if details.keys.include? :to_json
                                     send(attribute).send details[:to_json]
                                   else
                                     instance_variable_get('@' + attribute.to_s)
                                   end
      end # end test_subject_attributes.keys.each do |attribute, details|
      raw_hash_form
    end # end json_hash

    # All the subclassses will inherit this constructor
    #
    # The argument is a Hash with keys from the appropriate keys defiend
    # in Chook::Subject.classes
    #
    def initialize(subject_data = nil)
      classname = self.class.const_get Chook::Subject::NAME_CONSTANT
      attribs = Chook::Subject.classes[classname]

      if subject_data
        subject_data.each do |key, value|
          # ignore unknown attributes. Shouldn't get any, but...
          next unless attribs[key]

          # does the value need conversion?
          converter = attribs[key][:converter]
          if converter
            value = converter.is_a?(Symbol) ? value.send(converter) : converter.call(value)
          end # if converter
          instance_variable_set(('@' + key.to_s), value)
        end # each key value
      else
        attribs.keys.each { |key| instance_variable_set(('@' + key.to_s), nil) }
      end # if subject_data
    end # init

  end # class TestSubject

end # module
