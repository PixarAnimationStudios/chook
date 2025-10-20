# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

Chook::Subject.classes[Chook::Subject::MOBILE_DEVICE] = {
  udid: {
    validation: String,
    randomizer: :mobile_udid,
    api_object_attribute: :udid
  },
  deviceName: {
    validation: String,
    randomizer: :word,
    api_object_attribute: :name
  },
  version: {
    validation: String,
    randomizer: :version,
    api_object_attribute: %i[network carrier_settings_version]
  },
  model: {
    validation: String,
    randomizer: :mobile_model,
    api_object_attribute: :model
  },
  bluetoothMacAddress: {
    validation: String, # :validate_mac_address,
    randomizer: :mac_address,
    api_object_attribute: :bluetooth_mac_address
  },
  wifiMacAddress: {
    validation: String, # :validate_mac_address,
    randomizer: :mac_address,
    api_object_attribute: :wifi_mac_address
  },
  imei: {
    validation: :imei,
    randomizer: :imei,
    api_object_attribute: %i[network imei]
  },
  icciID: {
    validation: String, # :iccid,
    randomizer: :iccid,
    api_object_attribute: %i[network iccid]
  },
  product: {
    # Product is null in the sample JSONs... And there isn't anything labeled "product" in JSS::API.get_rsrc("mobiledevices/id/#{id}")
    validation: NilClass,
    randomizer: :product,
    api_object_attribute: Chook::Procs::PRODUCT
  },
  serialNumber: {
    validation: :serial_number,
    randomizer: :mobile_serial_number,
    # sampler: :serial_number,
    api_object_attribute: :serial_number
  },
  userDirectoryID: {
    # userDirectoryID is -1 in the sample JSONs... And there isn't anything labeled "userDirectoryID" in JSS::API.get_rsrc("mobiledevices/id/#{id}")
    validation: String,
    randomizer: Chook::Procs::MOBILE_USERID,
    api_object_attribute: Chook::Procs::MOBILE_USERID
  },
  room: {
    validation: String,
    randomizer: :room,
    api_object_attribute: :room
  },
  osVersion: {
    validation: String,
    randomizer: :mobile_os_version,
    api_object_attribute: :os_version
  },
  osBuild: {
    validation: String,
    randomizer: :os_build,
    api_object_attribute: :os_build
  },
  modelDisplay: {
    validation: String,
    randomizer: :mobile_model,
    api_object_attribute: :model
  },
  username: {
    validation: String,
    randomizer: :random_word,
    api_object_attribute: :username
  },
  jssID: {
    validation: Integer,
    randomizer: :int,
    api_object_attribute: :id
  }
}
