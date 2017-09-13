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

  # This module is a namespace holding all of the classes that are
  # subclasses of Chook::TestSubject, q.v.
  #
  module TestSubjects

    # Computer
    class Computer

      def self.sample(ids = 'random', api: JSS.api)
        ids = [ids] if ids.is_a? Integer
        all_computer_ids = JSS::Computer.all_ids(api: api)
        ids = [all_computer_ids.sample] if ids == 'random'

        ok = true
        if ids.is_a? Array
          ids.each { |id| ok == false unless id.is_a? Integer }
        else
          ok = false
        end
        raise 'ids must be an Integer, or an Array of Integers' unless ok

        samples = []
        computers = []

        valid_computer_ids = ids & all_computer_ids
        raise 'No valid Computer IDs' if valid_computer_ids.empty?

        valid_computer_ids.each do |id|
          computers << JSS::Computer.fetch(id: id, api: api)
        end
        computers.each do |computer|
          subject_details = {}
          Chook::Subject.classes[Chook::Subject::COMPUTER].map do |subject_key, attribute_values|
            extractor = attribute_values[:api_object_attribute]

            subject_details[subject_key] =
              case extractor
              when Symbol
                computer.send extractor
              when Array
                method = extractor.shift
                raw_hash_keys = extractor
                method_result = computer.send(method)
                raw_hash_keys.each { |key| method_result = method_result[key] }
                method_result
              when Proc
                extractor.call computer
              end
          end # do |subject_key, attribute_values|
          samples << Chook::TestSubjects::Computer.new(subject_details)
        end # end computers.each do |computer|
        samples
      end # sample

      Chook::Subject.classes[Chook::Subject::COMPUTER].keys.each {|key| attr_reader key }

      def initialize(computer_hash)
        @udid = computer_hash[:udid]
        @name = computer_hash[:deviceName]
        @model = computer_hash[:model]
        @macAddress = computer_hash[:macAddress]
        @alternateMacAddress = computer_hash[:alternateMacAddress]
        @serialNumber = computer_hash[:serialNumber]
        @osVersion = computer_hash[:osVersion]
        @osBuild = computer_hash[:osBuild]
        @userDirectoryID = computer_hash[:userDirectoryID]
        @username = computer_hash[:username]
        @realName = computer_hash[:realName]
        @emailAddress = computer_hash[:emailAddress]
        @phone = computer_hash[:phone]
        @position = computer_hash[:position]
        @department = computer_hash[:department]
        @building = computer_hash[:building]
        @room = computer_hash[:room]
        @jssID = computer_hash[:jssID]
      end # end initialize

    end # class Computer

    # MobileDevice
    class MobileDevice

      def self.sample(ids = 'random', api: JSS.api)
        ids = [ids] if ids.is_a? Integer
        all_mobile_ids = JSS::MobileDevice.all_ids(api: api)
        ids = [all_mobile_ids.sample] if ids == 'random'

        ok = true
        if ids.is_a? Array
          ids.each { |id| ok == false unless id.is_a? Integer }
        else
          ok = false
        end
        raise 'ids must be an Integer, or an Array of Integers' unless ok

        samples = []
        mobile_devices = []

        valid_mobile_ids = ids & all_mobile_ids
        raise 'No valid Mobile Device IDs' if valid_mobile_ids.empty?

        valid_mobile_ids.each do |id|
          mobile_devices << JSS::MobileDevice.fetch(id: id, api: api)
        end

        mobile_devices.each do |mobile|
          subject_details = {}
          Chook::Subject.classes[Chook::Subject::MOBILE_DEVICE].map do |subject_key, attribute_values|
            extractor = attribute_values[:api_object_attribute]

            subject_details[subject_key] =
              case extractor
              when Symbol
                mobile.send extractor
              when Array
                method = extractor.shift
                raw_hash_keys = extractor
                method_result = mobile.send(method)
                raw_hash_keys.each { |key| method_result = method_result[key] }
                method_result
              when Proc
                extractor.call mobile
              end
          end # do |subject_key, attribute_values|
          samples << Chook::TestSubjects::MobileDevice.new(subject_details)
        end # end mobile
        samples
      end # end sample

      Chook::Subject.classes[Chook::Subject::MOBILE_DEVICE].keys.each {|key| attr_reader key }

      def initialize(mobile_device_hash)
        @udid = mobile_device_hash[:udid]
        @deviceName = mobile_device_hash[:deviceName]
        @version = mobile_device_hash[:version]
        @model = mobile_device_hash[:model]
        @bluetoothMacAddress = mobile_device_hash[:bluetoothMacAddress]
        @wifiMacAddress = mobile_device_hash[:wifiMacAddress]
        @imei = mobile_device_hash[:imei]
        @icciID = mobile_device_hash[:icciID]
        @product = mobile_device_hash[:product]
        @serialNumber = mobile_device_hash[:serialNumber]
        @userDirectoryID = mobile_device_hash[:userDirectoryID]
        @room = mobile_device_hash[:room]
        @osVersion = mobile_device_hash[:osVersion]
        @osBuild = mobile_device_hash[:osBuild]
        @modelDisplay = mobile_device_hash[:modelDisplay]
        @username = mobile_device_hash[:username]
        @jssID = mobile_device_hash[:jssID]
      end # end initialize

    end # end class MobileDevice

    # PatchSoftwareTitleUpdated
    class PatchSoftwareTitleUpdated

      def self.sample(ids = 'random', api: JSS.api)
        # If only one Patch ID is specified, convert it to an Array.
        ids = [ids] if ids.is_a? Integer

        # Grab a single random Patch ID if none were specified.
        ids = [Chook::Samplers.patch_id(api)] if ids == 'random'

        # Check data type on all elements of the ids Array
        ok = true
        if ids.is_a? Array
          ids.each { |id| ok == false unless id.is_a? Integer }
        else
          ok = false
        end
        raise 'ids must be an Integer, or an Array of Integers' unless ok
        # Empty Array to collect PatchSoftwareTitleUpdated hashes
        raw_patch_hashes = []
        # Intersection of input and all patch ids means that the resultant set is valid.
        valid_patch_ids = ids & Chook::Samplers.all_patch_ids('blah')
        raise 'No valid PatchSoftwareTitleUpdated IDs' if valid_patch_ids.empty?

        valid_patch_ids.each do |id|
          # These take forever :(
          raw_patch_hashes << api.get_rsrc("patches/id/#{id}")
        end
        samples = []
        raw_patch_hashes.each do |patch_hash|
          subject_details = {}
          Chook::Subject.classes[Chook::Subject::PATCH_SW_UPDATE].each do |subject_key, attribute_values|
            if attribute_values[:sampler]
              extractor = attribute_values[:sampler]
              call_object = Chook::Samplers
            else
              extractor = attribute_values[:randomizer]
              call_object = Chook::Randomizer
            end
            subject_details[subject_key] =
              case extractor
              when Symbol
                call_object.send(extractor, patch_hash)
              # when Array
                # api.get_rsrc(extractor[0])
                # method = extractor.shift
                # raw_hash_keys = extractor
                # method_result = call_object.send(method)
                # raw_hash_keys.each { |key| method_result = method_result[key] }
                # method_result
              when Proc
                extractor.call nil
              end
          end # do |subject_key, attribute_values|
          samples << Chook::TestSubjects::PatchSoftwareTitleUpdated.new(subject_details)
        end # number_of_samples times
        samples
      end # end sample

      Chook::Subject.classes[Chook::Subject::PATCH_SW_UPDATE].keys.each {|key| attr_reader key }

      def initialize(patch_hash)
        @name = patch_hash[:name]
        @latestVersion = patch_hash[:latestVersion]
        @lastUpdate = patch_hash[:lastUpdate]
        @reportUrl = patch_hash[:reportUrl]
        @jssID = patch_hash[:jssID]
      end # end initialize

    end # class PatchSoftwareTitleUpdated

  end # module TestSubjects

end # module
