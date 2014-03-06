Doc = require("models/doc")
# 文稿展示
class DocDetail extends Spine.Controller
	className: "doc_detail ipanel"
	render: =>
		@html require("views/doc_detail")(@item || Doc.last())
	active: (params) ->
		super
		doc = Doc.select (items) ->
			items["_id"] is params.id
		if @item = doc[0]
			@render()
		else
			Doc.one "refresh", @render
			Doc.fetch id:params.id

module.exports = DocDetail
