# 控制画布大小扩展
DrawingBoard.Control.SwitchSize = DrawingBoard.Control.extend
	name: "switch_size"
	initialize: ->
		@$el.append require("views/widgets/switch_size")()
		handler = (e) =>
			e.preventDefault()
			$(e.currentTarget).addClass("active").siblings().removeClass "active"
			size = $(e.currentTarget).data("size")
			@board.$el.width size
			@board.resize()
			@board.reset()
		@$el.on "click", ".drawing-board-control-size-button",handler

# 下载绘图到本地
DrawingBoard.Control.Download = DrawingBoard.Control.extend
	name: 'download'
	initialize: ->
		@$el.append require("views/widgets/download")()
		@$el.on 'click', '.drawing-board-control-download-button', (e) =>
			@board.downloadImg()
			e.preventDefault()

