# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

# this module is just a namespace so we don't conflict with other handlers
module APIOpHandler

  REPORT_ACTIONS = {
    'PUT' => 'update',
    'POST' => 'create',
    'DELETE' => 'delete'
  }.freeze

end

Chook.event_handler do |event|
  event.logger.debug "This is a handler-level debug message for event #{event.object_id}"

  action = APIOpHandler::REPORT_ACTIONS[event.subject.restAPIOperationType]

  break unless action

  event.logger.info "API #{action}: #{event.subject.objectTypeName} '#{event.subject.objectName}' (id #{event.subject.objectID})"
end
