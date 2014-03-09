# 将绘图复制粘贴到编辑器扩展
DrawingBoard.Control.PasteToEditor = DrawingBoard.Control.extend
	name: "paste"
	initialize: ->
		@$el.append require("views/widgets/paste")()
		handler = (e) =>
			$("#editor").focus()
			dataUrl = @board.getImg()
			document.execCommand('insertimage', 0,dataUrl)
			e.preventDefault()
			$("#toggle-drawing").trigger "click"
			$("#editor").focus()
		@$el.on "click", ".drawing-board-control-paste-button",handler

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

