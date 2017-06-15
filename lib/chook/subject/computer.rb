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

# Add the attrbutes of a Computer subject to the Chook::Subject.attributes
# hash, to be used in defining Chook::TestSubjects::Computer and
# Chook::HandledSubjects::Computer
#
Chook::Subject.classes[Chook::Subject::COMPUTER] = {
  udid: {
    validation: String,
    randomizer: :udid,
    sampler: :uuid,
    api_object_attribute: :udid
  },
  deviceName: {
    validation: String,
    randomizer: :word,
    sampler: :device_name,
    api_object_attribute: :name
  },
  model: {
    validation: String,
    randomizer: :model,
    sampler: :model,
    api_object_attribute: [:hardware, :model]
  },
  macAddress: {
    validation: String, #:validate_mac_address,
    randomizer: :mac_address,
    sampler: :mac_address,
    api_object_attribute: :mac_address
  },
  alternateMacAddress: {
    validation: String, #:validate_mac_address,
    randomizer: :mac_address,
    sampler: :mac_address,
    api_object_attribute: :alt_mac_address
  },
  serialNumber: {
    validation: String, #:validate_serial_number,
    randomizer: :computer_serial_number,
    sampler: :serial_number,
    api_object_attribute: :serial_number
  },
  osVersion: {
    validation: String,
    randomizer: :os_version,
    sampler: :os_version,
    api_object_attribute: [:hardware, :os_version]
  },
  osBuild: {
    validation: String,
    randomizer: :os_build,
    sampler: :os_build,
    api_object_attribute: [:hardware, :os_build]
  },
  userDirectoryID: {
    validation: String, # Integer,
    randomizer: :int,
    sampler: :user_directory_id,
    api_object_attribute: nil
  },
  username: {
    validation: String,
    randomizer: :random_word,
    sampler: :username_sampler,
    api_object_attribute: :username
  },
  realName: {
    validation: String,
    randomizer: :random_name,
    sampler: :real_name_sampler,
    api_object_attribute: :real_name
  },
  emailAddress: {
    validation: String, #:validate_email,
    randomizer: :random_email,
    sampler: :email_sampler,
    api_object_attribute: :email_address
  },
  phone: {
    validation: String, #:validate_phone_number,
    randomizer: :phone,
    sampler: :phone_number,
    api_object_attribute: :phone
  },
  position: {
    validation: String,
    randomizer: :word,
    sampler: :position,
    api_object_attribute: :position
  },
  department: {
    validation: String,
    randomizer: :word,
    sampler: :department,
    api_object_attribute: :department
  },
  building: {
    validation: String,
    randomizer: :word,
    sampler: :building,
    api_object_attribute: :building
  },
  room: {
    validation: String,
    randomizer: :room,
    sampler: :room,
    api_object_attribute: :room
  },
  jssID: {
    validation: Integer,
    randomizer: :int,
    sampler: :jssid,
    api_object_attribute: :id
  }
}