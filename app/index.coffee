require('lib/setup')

DocList = require("controllers/doc_list")

BaseEditor = require("controllers/base_editor")
Doc = require("models/doc")

class App extends BaseEditor
	el: "article"
	className: "container"
	constructor: ->
		super
		Doc.bind "save", @afterSave
		Doc.bind "edit", @handleEdit
		@initEditor($('#editor'))
		@initDrawBoard("drawing-panel")
	onSubmit: (e) ->
		e.preventDefault()
		$title = $("input[name='title']",@$el)
		if $title.val() is ""
			@flash "标题不能为空","danger"
			$title.focus()
			return false
		if data = @getFormData()
			Doc.create data
	afterSave: =>
		@flash "已保存","success"
		$(".brand").removeClass "loading"
		$(".doc-list-menu").trigger "click"
	handleEdit: (item) =>
		$(".doc-list-menu").trigger "click"
		@renderWithData(item.attributes())

class Nav extends Spine.Controller
	el: "header"
	events:
		"click .doc-list-menu": "handleDocBox"
		"click .save-doc": "saveDoc"
		"click .new-doc": "newDoc"
	constructor: ->
		super
		@doc_box = new DocList()
		@app = new App()
	handleDocBox: (e) ->
		if $(e.currentTarget).hasClass "active"
			@doc_box.hide()
		else
			@doc_box.show()
			$(window).scrollTop(0)
		$(e.currentTarget).toggleClass "active"
	saveDoc: (e) ->
		@app.$el.find("form").submit()
	newDoc: (e) ->
		@app.$el.find("form")[0].reset()
		@app.resetDoc()

$ ->
	# Spine.Model.host = "http://iweb.17up.org/api"
	Spine.Model.host = "http://192.168.1.103:3000/api"
	new Nav()
