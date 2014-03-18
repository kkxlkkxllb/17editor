require = window.require

describe 'The Doc Model', ->
	Doc = require('models/doc')

	it 'should fetch success', ->
		Doc.fetch {},clear: true
		Doc.one "refresh",(items) ->
			expect(items.length).toEqual(2)
