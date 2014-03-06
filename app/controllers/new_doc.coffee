BaseEditor = require("controllers/base_editor")
# 新建文稿
class NewDoc extends BaseEditor
	className: "new_doc ipanel"
	editor_id: 1
	render: ->
		@loaded = true
		@html require("views/new_doc")(editor_id: @editor_id)
	active: ->
		super
		unless @loaded
			@render()
			@setup()

module.exports = NewDoc
