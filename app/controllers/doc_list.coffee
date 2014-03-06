Doc = require("models/doc")
# 文稿列表
class DocList extends Spine.Controller
	className: "doc_list ipanel"
	constructor: ->
		super
	render: ->
		@loaded = true
		@html require("views/doc_list")()
	active: ->
		super
		unless @loaded
			@render()

module.exports = DocList
