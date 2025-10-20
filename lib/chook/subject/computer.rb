# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

# Add the attrbutes of a Computer subject to the Chook::Subject.attributes
# hash, to be used in defining Chook::TestSubjects::Computer and
# Chook::HandledSubjects::Computer
#
Chook::Subject.classes[Chook::Subject::COMPUTER] = {
  udid: {
    validation: String,
    randomizer: :computer_udid,
    api_object_attribute: :udid
  },
  deviceName: {
    validation: String,
    randomizer: :word,
    api_object_attribute: :name
  },
  model: {
    validation: String,
    randomizer: :computer_model,
    api_object_attribute: %i[hardware model]
  },
  macAddress: {
    validation: String, # :validate_mac_address,
    randomizer: :mac_address,
    api_object_attribute: :mac_address
  },
  alternateMacAddress: {
    validation: String, # :validate_mac_address, # TODO: sometimes this value is nil !
    randomizer: :mac_address,
    api_object_attribute: :alt_mac_address
  },
  serialNumber: {
    validation: String, # :validate_serial_number,
    randomizer: :computer_serial_number,
    api_object_attribute: :serial_number
  },
  osVersion: {
    validation: String,
    randomizer: :computer_os_version,
    api_object_attribute: %i[hardware os_version]
  },
  osBuild: {
    validation: String,
    randomizer: :os_build,
    api_object_attribute: %i[hardware os_build]
  },
  userDirectoryID: {
    validation: String,
    randomizer: :int,
    api_object_attribute: Chook::Procs::COMPUTER_USERID
  },
  username: {
    validation: String,
    randomizer: :word,
    api_object_attribute: :username
  },
  realName: {
    validation: String,
    randomizer: :name,
    api_object_attribute: :real_name
  },
  emailAddress: {
    validation: String, # :validate_email,
    randomizer: :email_address,
    api_object_attribute: :email_address
  },
  phone: {
    validation: String, # :validate_phone_number,
    randomizer: :phone,
    api_object_attribute: :phone
  },
  position: {
    validation: String,
    randomizer: :word,
    api_object_attribute: :position
  },
  department: {
    validation: String,
    randomizer: :word,
    api_object_attribute: :department
  },
  building: {
    validation: String,
    randomizer: :word,
    api_object_attribute: :building
  },
  room: {
    validation: String,
    randomizer: :room,
    api_object_attribute: :room
  },
  jssID: {
    validation: Integer,
    randomizer: :int,
    api_object_attribute: :id
  }
}
