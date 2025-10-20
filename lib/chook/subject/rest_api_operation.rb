# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#
Chook::Subject.classes[Chook::Subject::REST_API_OPERATION] = {
  operationSuccessful: {
    validation: :boolean,
    randomizer: :bool
    # sampler: ,
    # api_object_attribute: :operationSuccessful
  },
  objectID: {
    validation: Integer,
    randomizer: :int
    # sampler: ,
    # api_object_attribute: :objectID
  },
  objectName: { # This can be "" if the object doesn't have a name attribute.
    validation: String,
    randomizer: :word
    # sampler: ,
    # api_object_attribute: :objectName
  },
  objectTypeName: {
    validation: String,
    randomizer: :word
    # sampler: ,
    # api_object_attribute: :objectTypeName
  },
  authorizedUsername: {
    validation: String,
    randomizer: :word
    # sampler: :username,
    # api_object_attribute: :authorizedUsername
  },
  restAPIOperationType: {
    validation: String,
    randomizer: :rest_operation
    # sampler: ,
    # api_object_attribute: :restAPIOperationType
  }
}
