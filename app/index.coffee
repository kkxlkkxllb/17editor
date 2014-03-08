require('lib/setup')

DocList = require("controllers/doc_list")

BaseEditor = require("controllers/base_editor")
Doc = require("models/doc")

class App extends BaseEditor
	el: "article"
	className: "container"
	events:
		"click .new-doc": "newDoc"
	constructor: ->
		super
		Doc.bind "save", @afterSave
		Doc.bind "edit", @handleEdit
		@initEditor($('#editor'))
	onSubmit: (e) ->
		e.preventDefault()
		if data = @getFormData()
			Doc.create data
	afterSave: =>
		@flash "已保存","success"
		$(".brand").removeClass "loading"
		$(".doc-list-menu").trigger "click"
	newDoc: (e) ->
		$("form",@$el)[0].reset()
		@resetDoc()
	handleEdit: (item) =>
		$(".doc-list-menu").trigger "click"
		@renderWithData(item.attributes())

$ ->
	# Spine.Model.host = "http://iweb.17up.org/api"
	Spine.Model.host = "http://192.168.1.103:3000/api"
	new App()
	list = new DocList()
	$(".doc-list-menu").on "click", ->
		if $(@).hasClass "active"
			list.hide()
		else
			list.show()
		$(@).toggleClass "active"
