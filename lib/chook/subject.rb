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

module Chook

  # This is the MetaClass for all Subject objects, both handled and test.
  # It holds constants, methods, and attributes that are common to all
  # subjects in Chook
  #
  # A 'subject' within Chook is the ruby-abstraction of a the 'event_object'
  # part of the JSON payload of an event.
  #
  # All events contain a #subject attribute, which represent the thing
  # upon which the event acted, e.g. a computer, mobile divice, or the
  # JSS itself.
  # Those attributes are objects which are subclasses of Chook::Subject, q.v.
  #
  class Subject

    # the various subclasses of Subject will have a constant
    # SUBJECT_NAME that contains a string - the name of the
    # subject as known to the JSS
    NAME_CONSTANT = 'SUBJECT_NAME'.freeze

    # The name of the Computer subject (a.k.a. 'event_object')
    # as known to the JSS. Also the class name of such subjects in
    # Chook::HandledSubjects and Chook::TestSubjects
    COMPUTER = 'Computer'.freeze

    # The name of the JSS subject (a.k.a. 'event_object')
    # as known to the JSS. Also the class name of such subjects in
    # Chook::HandledSubjects and Chook::TestSubjects
    JAMF_SOFTWARE_SERVER = 'JSS'.freeze

    # The name of the MobileDevice subject (a.k.a. 'event_object')
    # as known to the JSS. Also the class name of such subjects in
    # Chook::HandledSubjects and Chook::TestSubjects
    MOBILE_DEVICE = 'MobileDevice'.freeze

    # The name of the PatchSoftwareTitleUpdated subject (a.k.a. 'event_object')
    # as known to the JSS. Also the class name of such subjects in
    # Chook::HandledSubjects and Chook::TestSubjects
    PATCH_SW_UPDATE = 'PatchSoftwareTitleUpdated'.freeze

    # The name of the Push subject (a.k.a. 'event_object')
    # as known to the JSS. Also the class name of such subjects in
    # Chook::HandledSubjects and Chook::TestSubjects
    PUSH = 'Push'.freeze

    # The name of the RestAPIOperation subject (a.k.a. 'event_object')
    # as known to the JSS. Also the class name of such subjects in
    # Chook::HandledSubjects and Chook::TestSubjects
    REST_API_OPERATION = 'RestAPIOperation'.freeze

    # The name of the SCEPChallenge subject (a.k.a. 'event_object')
    # as known to the JSS. Also the class name of such subjects in
    # Chook::HandledSubjects and Chook::TestSubjects
    SCEP_CHALLENGE = 'SCEPChallenge'.freeze

    # The name of the SmartGroup subject (a.k.a. 'event_object')
    # as known to the JSS. Also the class name of such subjects in
    # Chook::HandledSubjects and Chook::TestSubjects
    SMART_GROUP = 'SmartGroup'.freeze

    # Define a 'classes' class method (actually a class-instance attribute)
    # that defines all of the possible Subject subclasses so they can
    # be dynamically created.
    #
    # The definitions will be added as the subject-files are loaded.
    #
    # This method returns a Hash with one item per subject-type.
    #
    # The key is the subject name [String] as known to the JSS and is defined
    # in a Constant in Chook::Subject, e.g. Chook::Subject::COMPUTER = 'Computer'.
    # That name is also used for the class names of the subject classes
    # in the HandledSubjects and TestSubjects modules.
    #
    # The values are also hashes, with one item per attribute for that
    # subject-type.  The keys are the attribute names as Symbols, and the
    # values are hashes defining the attribute. Attributes may have these keys:
    #    :converter => a Proc or a method-name (as a Symbol) to convert the raw
    #      value to its interally stored version. E.g. Time objects in JSON
    #      are left as Strings by the JSON.parse method. A converter can be
    #      used to make it a Time object.
    #    :validation => Class or Proc. When creating a TestSubject, this
    #      attribute is settable, and new values are validated. If a Class, then
    #      the new value must be an instance of the class. If a Proc, the value
    #      is passed to the proc, which must return True.
    #    :randomizer => Symbol. When creating a TestSubject,
    #      this is the class-method to call on Chook::TestSubject
    #      to generate a valid random value for this attribute.
    #    :sampler => Symbol: When creating a TestSubject, this is the
    #      Chook::TestSubject class method which will pull a random value from
    #      a real JSS.
    #    :api_object_attribute => Symbol or Array of Symbols or a Proc:
    #       When creating a TestSubject, this represents the location of values in an API object
    #       Symbol: A method name to call on an API object
    #       Array: Array[0] is a method name to call on an API object
    #         subsequent items are Hash keys to be called on Array[0]'s output
    #       Proc: Pass an API object to the PROC to get a value
    #
    def self.classes
      @classes
    end
    @classes = {}

  end # class Subject

end # module

# The subject definitions must be loaded before the meta classes
# so that the metaclasses can create the subject classes
require 'chook/subject/computer'
require 'chook/subject/jss'
require 'chook/subject/mobile_device'
require 'chook/subject/patch_software_title_update'
require 'chook/subject/push'
require 'chook/subject/rest_api_operation'
require 'chook/subject/scep_challenge'
require 'chook/subject/smart_group'
require 'chook/test_subjects'
