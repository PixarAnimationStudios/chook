# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

Chook.event_handler do |event|
  event.logger.debug "Computer Smart Group Changed: #{event.subject.name}"
  event.logger.debug "  Additions: #{event.subject.groupAddedDevicesIds.join ', '}"
  event.logger.debug "  Removals: #{event.subject.groupRemovedDevicesIds.join ', '}"
end
