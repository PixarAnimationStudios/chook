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

  # This is the MetaClass for all Event objects, both handled and test.
  # It holds constants, methods, and attributes that are common to all
  # events in Chook.
  #
  # An 'event' within Chook is the ruby-abstraction of a JSON payload
  # as sent by a JSS Webhook representing an event that takes place in the JSS.
  #
  # All events contain a #subject attribute, which represent the thing
  # upon which the event acted, e.g. a computer, mobile divice, or the
  # JSS itself.
  # The #subject attribute contains an object which is a subclass
  # of Chook::Subject, q.v.
  #
  class Event

    # A mapping of the Event Names (as they are known to the JSS)
    # to the the matching Subject class names
    #
    # The event names from the JSS are in the JSON hash as the value of
    # JSON_hash[:webhook][:webhookEvent] and they are also the names
    # of the matching event classes within the HandledEvent module and the
    # TestEvent module.
    #
    # E.g.
    # the HandledEvents class that handles the 'ComputerPolicyFinished'
    # event is Chook::HandledEvent::ComputerPolicyFinished
    #
    # and
    #
    # the TestEvents that simulates 'ComputerPolicyFinished' is
    # Chook::TestEvents::ComputerPolicyFinished
    #
    # And, those classes take the matching 'Computer' subject, either
    # Chook::HandledSubjects::Computer or Chook::TestSubjects::Computer
    #
    EVENTS = {
      'ComputerAdded' => Chook::Subject::COMPUTER,
      'ComputerCheckIn' => Chook::Subject::COMPUTER,
      'ComputerInventoryCompleted' => Chook::Subject::COMPUTER,
      'ComputerPolicyFinished' => Chook::Subject::COMPUTER,
      'ComputerPushCapabilityChanged' => Chook::Subject::COMPUTER,
      'DeviceAddedToDEP' => Chook::Subject::DEP_DEVICE,
      'JSSShutdown' => Chook::Subject::JAMF_SOFTWARE_SERVER,
      'JSSStartup' => Chook::Subject::JAMF_SOFTWARE_SERVER,
      'MobileDeviceCheckIn' => Chook::Subject::MOBILE_DEVICE,
      'MobileDeviceCommandCompleted' => Chook::Subject::MOBILE_DEVICE,
      'MobileDeviceEnrolled' => Chook::Subject::MOBILE_DEVICE,
      'MobileDevicePushSent' => Chook::Subject::MOBILE_DEVICE,
      'MobileDeviceUnEnrolled' => Chook::Subject::MOBILE_DEVICE,
      'PatchSoftwareTitleUpdated' => Chook::Subject::PATCH_SW_UPDATE,
      'PolicyFinished' => Chook::Subject::POLICY_FINISHED,
      'PushSent' => Chook::Subject::PUSH,
      'RestAPIOperation' => Chook::Subject::REST_API_OPERATION,
      'SCEPChallenge' => Chook::Subject::SCEP_CHALLENGE,
      'SmartGroupComputerMembershipChange' => Chook::Subject::SMART_GROUP,
      'SmartGroupMobileDeviceMembershipChange' => Chook::Subject::SMART_GROUP
    }.freeze

    # Event subclasses will have an EVENT_NAME constant,
    # which contains the name of the event, one of the keys
    # from the Event::EVENTS Hash.
    EVENT_NAME_CONST = 'EVENT_NAME'.freeze

    # Event subclasses will have a SUBJECT_CLASS constant,
    # which contains the class of the subject of the event, based on one of the
    # values from the Event::EVENTS Hash.
    SUBJECT_CLASS_CONST = 'SUBJECT_CLASS'.freeze

    #### Attrbutes common to all events

    # @return [String] A unique identifier for this chook event
    attr_reader :id

    # @return [Integer] The webhook id in the JSS that caused this event
    attr_reader :webhook_id

    # @return [String] The webhook name in the JSS that caused this event
    attr_reader :webhook_name

    # @return [Object] The subject of this event - i.e. the thing it acted upon.
    #   An instance of a class from either the Chook::HandledSubjects module
    #   or the Chook::TestSubjects module
    attr_reader :subject

    # @return [String, nil] If this event object was initialized with a JSON
    #  blob as from the JSS, it will be stored here.
    attr_reader :raw_json

    # @return [Hash, nil] If this event object was initialized with a JSON
    #  blob as from the JSS, the Hash parsed from it will be stored here.
    attr_reader :parsed_json

    # Args are a hash (or group of named params)
    # with these possible keys:
    #   raw_json: [String] A raw JSON blob for a full event as sent by the JSS
    #     If this is present, all other keys are ignored and the instance is
    #     built with this data.
    #   parsed_json: [Hash] A pre-parsed JSON blob for a full event.
    #     If this is present, all other keys are ignored and the instance is
    #     built with this data (however raw_json wins if both are provided)
    #   webhook_event: [String] The name of the event, one of the keys of EVENTS
    #   webhook_id: [Integer] The id of the webhook defined in the JSS
    #   webhook_name: [String] The name of the webhook defined in the JSS
    # The remaning keys are the attributes of the Subject subclass for this
    # event. Any not provided will be nil.
    #
    def initialize(**args)
      @id = "#{Time.now.to_i}-#{SecureRandom.urlsafe_base64 8}"
      if args[:raw_json]
        @raw_json = args[:raw_json]
        @parsed_json = JSON.parse @raw_json, symbolize_names: true
      elsif args[:parsed_json]
        @parsed_json = args[:parsed_json]
      end

      if @parsed_json
        @webhook_name = @parsed_json[:webhook][:name]
        @webhook_id = @parsed_json[:webhook][:id]
        subject_data = @parsed_json[:event]
      else
        @webhook_name = args.delete :webhook_name
        @webhook_id = args.delete :webhook_id
        subject_data = args
      end

      @subject = self.class::SUBJECT_CLASS.new subject_data
    end

  end # class Event

end # module
