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
Chook::Subject.classes[Chook::Subject::REST_API_OPERATION] = {
  operationSuccessful: {
    validation: :boolean,
    randomizer: :bool
    # sampler: ,
    # api_object_attribute: :operationSuccessful
  },
  objectID: {
    validation: Integer,
    randomizer: :int,
    # sampler: ,
    # api_object_attribute: :objectID
  },
  objectName: { # This can be "" if the object doesn't have a name attribute.
    validation: String,
    randomizer: :word,
    # sampler: ,
    # api_object_attribute: :objectName
  },
  objectTypeName: {
    validation: String,
    randomizer: :word, # Most (but not all) API resources. e.g. "Patch Reporting Software Title", "Mobile Device", "Static Computer Group"
    # sampler: ,
    # api_object_attribute: :objectTypeName
  },
  authorizedUsername: {
    validation: String,
    randomizer: :word,
    # sampler: :username,
    # api_object_attribute: :authorizedUsername
  },
  restAPIOperationType: {
    validation: String,
    randomizer: :rest_operation,
    # sampler: ,
    # api_object_attribute: :restAPIOperationType
  }
}
