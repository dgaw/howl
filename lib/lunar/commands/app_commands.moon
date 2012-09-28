import command, config from lunar

command.register
  name: 'q',
  description: 'Quits the application'
  inputs: {}
  handler: -> lunar.app\quit!

command.alias 'q', 'quit'

command.register
  name: 'switch-buffer',
  description: 'Switches to another buffer'
  inputs: { 'buffer' }
  handler: (buffer) ->
    _G.editor.buffer = buffer

command.register
  name: 'set',
  description: 'Sets a configuration variable'
  inputs: { 'variable_assignment' }
  handler: (assignment) ->
    if assignment.name
      value = assignment.value or ''
      config.set assignment.name, value
      _G.log.info ('"%s" is now set to "%s"')\format assignment.name, assignment.value
