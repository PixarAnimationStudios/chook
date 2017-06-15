# foundation
require 'chook/foundation'

# namespace modules
require 'chook/handled_subjects'
require 'chook/handled_events'

# subjects - must load before events.
require 'chook/subject'
require 'chook/subject/handled_subject'
Chook::HandledSubject.generate_classes

# events
require 'chook/event'
require 'chook/event/handled_event'
Chook::HandledEvent.generate_classes
