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
Chook::Subject.classes[Chook::Subject::POLICY_FINISHED] = {
  computer: {
    validation: Hash,
    api_object_attribute: :computer
  },
  policyId: {
    validation: Integer,
    api_object_attribute: :policyId
  },
  successful: {
    validation: :boolean,
    api_object_attribute: :successful
  }
}
