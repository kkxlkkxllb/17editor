BaseEditor = require("controllers/base_editor")
# 编辑文稿
class EditDoc extends BaseEditor
	className: "edit_doc ipanel"
	render: ->
		@loaded = true
		@html require("views/edit_doc")()
	active: ->
		super
		unless @loaded
			@render()

module.exports = EditDoc
