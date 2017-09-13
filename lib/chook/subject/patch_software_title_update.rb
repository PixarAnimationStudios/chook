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
Chook::Subject.classes[Chook::Subject::PATCH_SW_UPDATE] = {
  name: {
    validation: :patch,
    randomizer: :patch,
    sampler: :patch_name,
    # api_object_attribute: :name
  },
  latestVersion: {
    validation: String,
    randomizer: :version,
    sampler: :patch_latest_version,
    # api_object_attribute:
  },
  lastUpdate: {
    converter: Chook::Procs::JSS_EPOCH_TO_TIME,
    validation: Time,
    randomizer: :time,
    sampler: :patch_last_update,
    # api_object_attribute:
  },
  reportUrl: {
    validation: :url,
    randomizer: :url,
    sampler: :patch_report_url,
    # api_object_attribute:
  },
  jssID: {
    validation: Integer,
    randomizer: :int,
    sampler: :patch_id,
    # api_object_attribute: :id
  }
}
