# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#
Chook::Subject.classes[Chook::Subject::JAMF_SOFTWARE_SERVER] = {
  institution: {
    validation: String,
    randomizer: :word
    # sampler: :institution,
    # api_object_attribute: :institution
  },
  hostAddress: {
    validation: String,
    randomizer: :host
    # sampler: ,
    # api_object_attribute: :hostAddress
  },
  webApplicationPath: {
    validation: String
    # randomizer: ,
    # sampler: ,
    # api_object_attribute: :webApplicationPath
  },
  isClusterMaster: {
    validation: :boolean,
    randomizer: :bool
    # sampler: ,
    # api_object_attribute: :isClusterMaster
  },
  jssUrl: {
    validation: :url,
    randomizer: :url
    # sampler: ,
    # api_object_attribute: :jssUrl
  }
}
