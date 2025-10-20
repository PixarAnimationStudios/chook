# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#
Chook::Subject.classes[Chook::Subject::PATCH_SW_UPDATE] = {
  name: {
    validation: :patch,
    randomizer: :patch,
    api_object_attribute: :name
  },
  latestVersion: {
    validation: String,
    randomizer: :version,
    sampler: :patch_latest_version,
    api_object_attribute: :patch_latest_version
  },
  lastUpdate: {
    to_json: :to_jss_epoch,
    validation: Time,
    randomizer: :time,
    sampler: :patch_last_update,
    api_object_attribute: :patch_last_update
  },
  reportUrl: {
    validation: :url,
    randomizer: :url,
    sampler: :patch_report_url,
    api_object_attribute: :patch_report_url
  },
  jssID: {
    validation: Integer,
    randomizer: :int,
    api_object_attribute: :id
  }
}
