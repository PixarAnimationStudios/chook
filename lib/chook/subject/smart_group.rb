# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#
Chook::Subject.classes[Chook::Subject::SMART_GROUP] = {
  name: {
    validation: String,
    randomizer: :word,
    # sampler: :smart_group,
    api_object_attribute: :name
  },
  smartGroup: {
    validation: :boolean,
    randomizer: Chook::Procs::ALWAYS_TRUE, # If this were false, it wouldn't be a Smart Group...
    # sampler: Chook::Procs::ALWAYS_TRUE,
    api_object_attribute: :is_smart
  },
  jssid: {
    validation: Integer,
    randomizer: :int,
    # sampler: :smart_group_jssid,
    api_object_attribute: :id
  },
  groupAddedDevicesIds: {
    validation: Array
  },
  groupRemovedDevicesIds: {
    validation: Array
  },
  computer: { # SmartGroupComputerMembershipChange == true, SmartGroupMobileDeviceMembershipChange == false
    validation: :boolean,
    randomizer: :bool
    # sampler: ,
    # api_object_attribute: :computer
  }
}
