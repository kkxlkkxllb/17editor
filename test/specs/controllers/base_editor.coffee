require = window.require

describe 'The BaseEditor Controller', ->
	BaseEditor = require('controllers/base_editor')

	it 'can noop', ->
		expect(true).toBe(true)
