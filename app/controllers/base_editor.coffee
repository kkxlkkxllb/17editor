Notify = require("lib/utils/notify")
class BaseEditor extends Spine.Controller
	@include Notify
	events:
		"submit form": "onSubmit"
		"click .upload-picture": "uploadPic"
		"change .scale-img": "scaleImg"
		"click #editor img": "selectImg"
		"dragstart #editor img": "handleDragStart"
		"dragend #editor img": "handleDragEnd"
		"blur #editor": "handleBlur"
		"focus #editor": "handleFocus"
		"click .toggle-drawing": "toggleDrawing"
	initEditor: (@$editor) ->
		@$editor.wysiwyg
			fileUploadError: (reason, detail) =>
				@flash reason + detail
			afterUpload: =>
				$("img",@$editor).attr "draggable",true
				$(".picture_control",@$el).show()
		@$editor.on "drop", @handleDrop
		@$editor.on "dragover", @handleDragOver
		# 快捷键保存文稿
		@$editor.keydown "ctrl+s meta+s", (e) ->
			e.preventDefault()
			e.stopPropagation()
			$(@).closest("form").submit()
	initDrawBoard: (id) ->
		options =
			controls: [
				'Color'
				'Size'
				'DrawingMode'
				'Navigation'
				# 'Download'
				'PasteToEditor'
				'SwitchSize'
			]
			size: 2
			droppable: true
			webStorage: false
		@draw_board = new DrawingBoard.Board(id,options)
	toggleDrawing: (e) ->
		$("#drawing-panel").toggleClass "hide"
		$(e.currentTarget).toggleClass "active"
		unless @draw_board
			@initDrawBoard("drawing-panel")
	uploadPic: (e) ->
		target_id = $(e.currentTarget).attr "id"
		$("input[data-target='#{target_id}']").trigger "click"
	selectImg: (e) ->
		$img = $(e.currentTarget)
		$img.addClass("active").siblings().removeClass("active")
		rate = parseFloat $img.width()/$img[0].naturalWidth
		$input = $(".scale-img",@$el)
		$input.val(rate).prev().find(".num").text parseFloat(rate).toFixed(2)
	scaleImg: (e) ->
		$target = $(e.currentTarget)
		rate = $target.val()
		$target.prev().find(".num").text parseFloat(rate).toFixed(2)
		$img = $("img.active",@$editor)
		if !$img.length
			$img = $("img:eq(0)",@$editor)
		unless !$img.length
			$img.width $img[0].naturalWidth * rate
	handleBlur: (e) ->
		$imgs = @handleFocus(e)
		$imgs.removeClass "active"
		@$editor.prev().val @$editor.cleanHtml()
	handleFocus: (e) ->
		$imgs = $(e.currentTarget).find("img")
		if $imgs.length > 0
			$(".picture_control",@$el).show()
		else
			$(".picture_control",@$el).hide()
		$imgs
	handleDragStart: (e) ->
		position = $(e.currentTarget).addClass("dragging").position()
		event = e.originalEvent
		text = (position.left - event.clientX) + "," + (position.top - event.clientY)
		event.dataTransfer.setData "text/plain",text
	handleDragOver: (e) ->
		e.preventDefault()
		false
	handleDragEnd: (e) ->
		$(e.currentTarget).removeClass("dragging")
	handleDrop: (e) ->
		e.stopPropagation()
		e.preventDefault()
		event = e.originalEvent
		offset = event.dataTransfer.getData("text/plain").split(",")
		$("img.dragging",@$editor).css
			"left": (event.clientX + parseInt(offset[0],10)) + "px"
			"top": (event.clientY + parseInt(offset[1],10)) + "px"
	getFormData: ->
		html = @$editor.cleanHtml()
		if html is ""
			@flash "正文内容不允许为空","danger"
			@$editor.focus()
			return false
		$(".brand").addClass "loading"
		@$editor.closest("form").serializeObject()
	resetDoc: ->
		@$editor.empty().focus()
		@draw_board.reset(background: true) if @draw_board
	renderWithData: (data) ->
		$form = @$editor.closest("form")
		$.each $("input[name],textarea[name]",$form), (i,e) ->
			key = $(e).attr "name"
			$(e).val data[key]
		@$editor.html(data.raw_content).focus()


module.exports = BaseEditor
