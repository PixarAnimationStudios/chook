# foundation
require 'chook/foundation'

# namespace modules
require 'chook/test_subjects'
require 'chook/test_events'

# subjects - must load before events.
require 'chook/subject'
require 'chook/subject/test_subject'
# Chook::TestSubject.generate_classes

# testing data generation
require 'chook/subject/randomizers'
require 'chook/subject/samplers'
require 'chook/subject/validators'

# events
require 'chook/event'
require 'chook/event/test_event'
# Chook::TestEvent.generate_classes
