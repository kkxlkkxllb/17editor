Doc = require("models/doc")
DocItem = require("controllers/doc_item")
# 文稿列表
class DocList extends Spine.Controller
	el: "#doc-list"
	constructor: ->
		super
		Doc.bind "refresh", @render
		Doc.fetch {},clear: true
	render: (items) =>
		items = [].concat items
		for doc in items
			view = new DocItem(item: doc)
			if items.length is 1
				$(".container",@$el).prepend view.render()
			else
				$(".container",@$el).append view.render()
	hide: ->
		@$el.hide()
	show: ->
		@$el.show()

module.exports = DocList
