# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#
Chook::Subject.classes[Chook::Subject::PUSH] = {
  type: { # TODO: "PushSent" for a Computer or "MobileDevicePushSent" for a Mobile Device
    validation: String,
    randomizer: :push
    # sampler:,
    # api_object_attribute: :type
  },
  jssID: {
    validation: Integer,
    randomizer: :int
    # sampler: :jssid, # TODO: This should be computer_jssid or mobile_jssid based on the type, see above
    # api_object_attribute: :id
  }
}
