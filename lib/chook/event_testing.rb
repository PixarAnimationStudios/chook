### Copyright 2025 Pixar

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
# foundation
require 'chook/foundation'

# subjects - must load before events.
require 'chook/subject'
require 'chook/subject/randomizers'
require 'chook/subject/samplers'
require 'chook/subject/validators'

# testing data generation
require 'chook/subject/test_subject'
require 'chook/test_subjects'
Chook::TestSubject.generate_classes

# events
require 'chook/event'
require 'chook/event/test_event'
require 'chook/test_events'
Chook::TestEvent.generate_classes
