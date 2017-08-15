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

Chook::Subject.classes[Chook::Subject::MOBILE_DEVICE] = {
  udid: {
    validation: String,
    randomizer: :mobile_udid,
    sampler: :mobile_udid,
    api_object_attribute: :udid
  },
  deviceName: {
    validation: String,
    randomizer: :word,
    sampler: :mobile_device_name,
    api_object_attribute: :name
  },
  version: {
    validation: String,
    randomizer: :version,
    sampler: :version,
    api_object_attribute: [:network, :carrier_settings_version]
  },
  model: {
    validation: String,
    randomizer: :mobile_model,
    sampler: :mobile_model,
    api_object_attribute: :model
  },
  bluetoothMacAddress: {
    validation: String, #:validate_mac_address,
    randomizer: :mac_address,
    sampler: :mobile_mac_address,
    api_object_attribute: :bluetooth_mac_address
  },
  wifiMacAddress: {
    validation: String, #:validate_mac_address,
    randomizer: :mac_address,
    sampler: :mobile_mac_address,
    api_object_attribute: :wifi_mac_address
  },
  imei: {
    validation: :imei,
    randomizer: :imei,
    sampler: :imei,
    api_object_attribute: [:network, :imei]
  },
  icciID: {
    validation: String, #:iccid,
    randomizer: :iccid,
    sampler: :iccid,
    api_object_attribute: [:network, :iccid]
  },
  product: {
    # Product is null in the sample JSONs... And there isn't anything labeled "product" in JSS::API.get_rsrc("mobiledevices/id/#{id}")
    validation: Nil,
    randomizer: :product,
    sampler: :product,
    api_object_attribute: Chook::Procs::PRODUCT
  },
  serialNumber: {
    validation: :serial_number,
    randomizer: :mobile_serial_number,
    sampler: :mobile_sserial_number,
    api_object_attribute: :serial_number
  },
  userDirectoryID: {
    # userDirectoryID is -1 in the sample JSONs... And there isn't anything labeled "userDirectoryID" in JSS::API.get_rsrc("mobiledevices/id/#{id}")
    validation: String,
    randomizer: Chook::Procs::MOBILE_USERID,
    sampler: Chook::Procs::MOBILE_USERID,
    api_object_attribute: Chook::Procs::MOBILE_USERID
  },
  room: {
    validation: String,
    randomizer: :room,
    sampler: :room,
    api_object_attribute: :room
  },
  osVersion: {
    validation: String,
    randomizer: :mobile_os_version,
    sampler: :mobile_os_version,
    api_object_attribute: :os_version
  },
  osBuild: {
    validation: String,
    randomizer: :os_build,
    sampler: :mobile_os_build,
    api_object_attribute: :os_build
  },
  modelDisplay: {
    validation: String,
    randomizer: :mobile_model,
    sampler: :model_display,
    api_object_attribute: :model
  },
  username: {
    validation: String,
    randomizer: :random_word,
    sampler: :mobile_username,
    api_object_attribute: :username
  },
  jssID: {
    validation: Integer,
    randomizer: :int,
    sampler: :mobile_jssid,
    api_object_attribute: :id
  }
}
