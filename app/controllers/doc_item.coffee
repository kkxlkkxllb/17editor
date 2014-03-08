Doc = require("models/doc")
# 文稿
class DocItem extends Spine.Controller
	className: "item col-sm-4"
	events:
		"click": "handleEdit"
		"click .delete": "handleDelete"
	constructor: ->
		super
		@item.bind "destroy",@release
		@item.bind "update", @release
	render: ->
		@html require("views/items/doc")(@item)
	handleEdit: (e) ->
		Doc.trigger "edit",@item
	handleDelete: (e) ->
		e.preventDefault()
		e.stopPropagation()
		if confirm "Are u sure?"
			@item.destroy()


module.exports = DocItem
