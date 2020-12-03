### Copyright 2020 Pixar

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
Chook::Subject.classes[Chook::Subject::DEP_DEVICE] = {
  assetTag: {
    validation: String,
    # randomizer: ,
    # sampler: ,
    # api_object_attribute:
  },
  description: {
    validation: String,
    randomizer: :word,
    # sampler: ,
    # api_object_attribute:
  },
  deviceAssignedDate: {
    to_json: :to_jss_epoch,
    validation: Time,
    randomizer: :time,
    # sampler: ,
    # api_object_attribute:
  },
  deviceEnrollmentProgramInstanceId: {
    validation: Integer,
    randomizer: :int,
    # sampler: ,
    # api_object_attribute:
  },
  model: {
    validation: String,
    randomizer: [:computer_model, :mobile_model], # /:
    # sampler: ,
    api_object_attribute: [:hardware, :model]
  },
  serialNumber: {
    validation: String, #:validate_serial_number,
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
