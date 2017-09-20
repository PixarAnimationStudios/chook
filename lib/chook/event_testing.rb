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
