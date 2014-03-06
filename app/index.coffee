require('lib/setup')
Spine = require('spine')

DocList = require("controllers/doc_list")
DocDetail = require("controllers/doc_detail")
NewDoc = require("controllers/new_doc")
EditDoc = require("controllers/edit_doc")

class App extends Spine.Stack
	el: "article"
	className: "container stack"
	controllers:
		new_doc: NewDoc
		edit_doc: EditDoc
		doc_detail: DocDetail
		doc_list: DocList
	routes:
		"": ->
			@navigate("/new", replace: true)
		"/new": "new_doc"
		"/doc/:id/edit": "edit_doc"
		"/doc/:id": "doc_detail"
		"/docs": "doc_list"

$ ->
	# Spine.Model.host = "http://iweb.17up.org/api"
	Spine.Model.host = "http://192.168.1.103:3000/api"
	new App()
	Spine.Route.setup()
