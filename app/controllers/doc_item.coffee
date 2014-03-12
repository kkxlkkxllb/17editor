Doc = require("models/doc")
# 文稿
class DocItem extends Spine.Controller
	className: "item col-sm-4"
	events:
		"click": "handleEdit"
		"click .delete": "handleDelete"
	constructor: ->
		super
		@item.one "destroy",@release
		@item.one "update", @release
	render: ->
		@html require("views/items/doc")(@item)
	handleEdit: (e) ->
		if @item.raw_content
			Doc.trigger "edit",@item
		else
			$(".brand").addClass "loading"
			@item.ajax().reload {},done: ->
				Doc.trigger "edit",@
				$(".brand").removeClass "loading"
	handleDelete: (e) ->
		e.preventDefault()
		e.stopPropagation()
		if confirm "Are u sure?"
			if @item.eql window.app.currentDoc
				$(".new-doc").trigger "click"
			@item.destroy()

module.exports = DocItem
