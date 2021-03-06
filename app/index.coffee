require('lib/setup')

DocList = require("controllers/doc_list")

BaseEditor = require("controllers/base_editor")
Doc = require("models/doc")

class App extends BaseEditor
	el: "article"
	className: "container"
	constructor: ->
		super
		Doc.bind "edit", @handleEdit
		Doc.bind "ajaxError", @handleAjaxError
		Doc.bind "serverError", @handleServerError
		@initEditor($('#editor'))
		@initSketch("drawing-panel")
		$('a[title]').tooltip(container: '.btn-toolbar')
	onSubmit: (e) ->
		super
		e.preventDefault()
		self = this
		$title = $("input[name='title']",@$el)
		if $title.val() is ""
			$title.focus()
			@flash "标题不能为空","danger"
			return false
		if data = @getFormData()
			Doc.create data, done: ->
				self.flash "已保存","success"
				$(".brand").removeClass "loading"
				self.renderWithData(@attributes())
				Doc.trigger "prepend", @
	handleEdit: (item) =>
		$(".doc-list-menu").trigger "click"
		@renderWithData(item.attributes())
		@currentDoc = item
		if $(".preview",@$el).hasClass "active"
			$(".preview",@$el).trigger "click"
	handleAjaxError: (xhr,stat,e) =>
		@flash "[#{stat.status}] #{e}","danger"
	handleServerError: (msg) =>
		@flash msg,"danger"

class Nav extends Spine.Controller
	el: "header"
	events:
		"click .doc-list-menu": "handleDocBox"
		"click .save-doc": "saveDoc"
		"click .new-doc": "newDoc"
	constructor: ->
		super
		window.app = new App()
		@doc_box = new DocList()
	handleDocBox: (e) ->
		tof = $(e.currentTarget).hasClass "active"
		@doc_box.$el.toggleClass "hide",tof
		$(window).scrollTop(0)
		$(e.currentTarget).toggleClass "active"
	saveDoc: (e) ->
		window.app.$el.find("form").submit()
	newDoc: (e) ->
		if $(".preview",window.app.$el).hasClass "active"
			$(".preview",window.app.$el).trigger "click"
		$form = window.app.$el.find("form")
		$form.find("input[type='hidden'],input[type='text'],textarea").val ""
		window.app.resetDoc()

$ ->
	Spine.Model.host = "http://iweb.17up.org/api"
	# Spine.Model.host = "http://192.168.1.103:3000/api"
	new Nav()
