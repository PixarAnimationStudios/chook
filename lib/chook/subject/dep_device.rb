# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#
Chook::Subject.classes[Chook::Subject::DEP_DEVICE] = {
  assetTag: {
    validation: String
    # randomizer: ,
    # sampler: ,
    # api_object_attribute:
  },
  description: {
    validation: String,
    randomizer: :word
    # sampler: ,
    # api_object_attribute:
  },
  deviceAssignedDate: {
    to_json: :to_jss_epoch,
    validation: Time,
    randomizer: :time
    # sampler: ,
    # api_object_attribute:
  },
  deviceEnrollmentProgramInstanceId: {
    validation: Integer,
    randomizer: :int
    # sampler: ,
    # api_object_attribute:
  },
  model: {
    validation: String,
    randomizer: %i[computer_model mobile_model], # /:
    # sampler: ,
    api_object_attribute: %i[hardware model]
  },
  serialNumber: {
    validation: String, # :validate_serial_number,
    # randomizer: :computer_serial_number,
    # sampler: ,
    api_object_attribute: :serial_number
  }
}

# https://www.jamf.com/developers/webhooks/#deviceaddedtoDEP
# {
#     "event": {
#         "assetTag": "1664194",
#         "description": "Mac Pro",
#         "deviceAssignedDate": 1552478234000,
#         "deviceEnrollmentProgramInstanceId": 1,
#         "model": "Mac Pro",
#         "serialNumber": "92D8014694C4BE96B3"
#     },
#     "webhook": {
#         "eventTimestamp": 1553550275590,
#         "id": 1,
#         "name": "Webhook Documentation",
#         "webhookEvent": "DeviceAddedToDEP"
#     }
# }
