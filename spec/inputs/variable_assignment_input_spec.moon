import inputs, config from lunar

require 'lunar.inputs.variable_assignment_input'

describe 'VariableAssignmentInput', ->

  it 'registers a "variable_assignment" input', ->
    assert_not_nil inputs.variable_assignment

  describe 'an instance of', ->
    readline = nil
    input = -> inputs.variable_assignment readline

    before -> readline = {}
    after -> readline = nil

    it '.should_complete() returns true', ->
      assert_true input!\should_complete!

    describe '.on_completed(text)', ->
      context 'when the assignment is incomplete', ->
        it 'returns false', ->
          readline.text = 'foo'
          assert_false input!\on_completed { 'foo', 'foo description' }

        it 'appends a "=" to the readline text', ->
          readline.text = 'foo'
          input!\on_completed { 'foo', 'foo description' }
          assert_equal readline.text, 'foo='

      it 'returns true if the assignment is complete', ->
        readline.text = 'foo=bar'
        assert_true input!\on_completed { 'foo', 'foo description' }

    describe '.complete(text)', ->
      before ->
        config.define name: 'hola_var', description: 'Yes!', options: { 'two', 'one' }

      context 'for the left hand side of the assignment', ->
        it 'returns variable names and descriptions', ->
          completions = [t for t in *input!\complete('hola') when t[1] == 'hola_var']
          assert_table_equal completions, { {'hola_var', 'Yes!' } }

      context 'for the right hand side of the assignment', ->
        it 'returns a sorted list of option values for a plain table', ->
          completions = input!\complete('hola_var=')
          assert_table_equal completions, { 'one', 'two' }

        it 'returns a sorted list of option values for a function generating options', ->
          config.define name: 'hola_var', description: 'Yes!', options: -> { 'two', 'one' }
          completions = input!\complete('hola_var=')
          assert_table_equal completions, { 'one', 'two' }

        it 'returns list options with `selection` set to current value if any', ->
          config.hola_var = 'two'
          _, options = input!\complete('hola_var=')
          assert_equal options.list.selection, 'two'

          config.hola_var = nil
          _, options = input!\complete('hola_var=')
          assert_nil options.list.selection

        it 'returns a sorted list of option values for options with descriptions', ->
          options = {
            { true, 'yes' }
            { false, 'no' }
          }

          config.define name: 'hola_var', description: 'Yes!', :options
          completions = input!\complete('hola_var=')
          assert_table_equal completions, {
            { 'false', 'no' }
            { 'true', 'yes' }
          }

      describe '.value_for(text)', ->
        it 'returns a table containing the assignment information', ->
          input = input!
          value = input\value_for('foo=bar')
          assert_table_equal value, name: 'foo', value: 'bar'
          assert_table_equal input\value_for('foo='), name: 'foo'
          assert_table_equal input\value_for('foo'), {}
