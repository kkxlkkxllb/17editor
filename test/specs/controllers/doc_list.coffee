require = window.require

describe 'The DocList Controller', ->
	DocList = require('controllers/doc_list')
	Doc = require("models/doc")


	it 'function defined', ->
		dl = new DocList()
		console.log dl
		spyOn dl,"render"
		waitsFor ->
			Doc.fetch()
		runs ->
			expect(dl.render).toHaveBeenCalled()
		# runs ->
		# 	expect(dl.render).toBeDefined()
		# 	expect(dl.prepend).toBeDefined()
		# 	expect(dl.render).toHaveBeenCalled()
