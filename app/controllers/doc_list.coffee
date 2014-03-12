Doc = require("models/doc")
DocItem = require("controllers/doc_item")
# 文稿列表
class DocList extends Spine.Controller
	el: "#doc-list"
	constructor: ->
		super
		Doc.one "refresh", @render
		Doc.bind "prepend", @prepend
		Doc.fetch {},clear: true
	render: (items) =>
		items = [].concat items
		for doc in items
			view = new DocItem(item: doc)
			$(".container",@$el).append view.render()
	prepend: (doc) =>
		view = new DocItem(item: doc)
		$(".container",@$el).prepend view.render()

module.exports = DocList
