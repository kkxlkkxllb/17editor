Utils = require("lib/utils/utils")
SketchTool = require("lib/utils/sketch_tool")

class BaseEditor extends Spine.Controller
	@include Utils
	@include SketchTool
	events:
		"submit form": "onSubmit"
		"change .scale-img": "scaleImg"
		"click #editor img": "selectImg"
		"dragstart #editor img": "handleDragStart"
		"dragend #editor img": "handleDragEnd"
		"blur #editor": "handleBlur"
		"focus #editor": "handleFocus"
		"click .preview": "preview"
		"click .upload-picture": "uploadPic"
		"shown.bs.modal .modal": "handleShowModal"
		"keyup .math-input": "handleMathInput"
		"keyup .link-input": "triggerSubmit"
		"change .inline-format": "triggerMathRender"
		# sketch
		"click .sketch_control .color-picker": "setColor"
		"click .sketch_control .clear": "clearSketch"
		"click .sketch_control .eraser": "setEraser"
		"click .sketch_control .pencil": "setPencil"
		"click .sketch_control .download": "downloadSketch"
		"change .sketch_control .size": "setLineWidth"

	initEditor: (@$editor) ->
		@$editor.wysiwyg
			fileUploadError: (reason, detail) =>
				@flash reason + detail
			afterUpload: =>
				$("img",@$editor).attr "draggable",true
				$(".picture_control",@$el).removeClass "hide"
			hotKeys:
				# 快捷键保存文稿
				"ctrl+s meta+s": (editor) ->
					$(editor).prev().val $(editor).cleanHtml()
					$(editor).closest("form").submit()
		@$editor.on "drop", @handleDrop
		@$editor.on "dragover", @handleDragOver
	onSubmit: (e) ->
		$("input[name='draw']",@$el).val @getSketchData()
	preview: (e) ->
		tof = $(e.currentTarget).hasClass("active")
		$(".editor-mian-wrapper",@$el).toggleClass "hide",!tof
		$(".preview-panel-wrapper",@$el).toggleClass "hide",tof
		$(e.currentTarget).parent().siblings().find("a.btn").toggleClass "disabled",!tof
		unless tof
			$("#preview-panel").html @$editor.html()
			MathJax.Hub.Queue(["Typeset",MathJax.Hub,"preview-panel"])
		$(e.currentTarget).toggleClass "active"
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
		@$editor.prev().val @$editor.cleanHtml()
	handleFocus: (e) ->
		$imgs = $(e.currentTarget).find("img")
		$(".picture_control",@$el).toggleClass "hide",!$imgs.length
		$imgs
	handleDragStart: (e) ->
		position = $(e.currentTarget).addClass("dragging").position()
		event = e.originalEvent
		event.dataTransfer.effectAllowed = 'linkMove'
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
		@sketch.clear()
	renderWithData: (data) ->
		$form = @$editor.closest("form")
		$.each $("input[name],textarea[name]",$form), (i,e) ->
			key = $(e).attr "name"
			$(e).val data[key]
		@$editor.html(data.raw_content).focus()
		# 如果有画板信息，则填充画板，否则清空
		@setSketchData data.draw

	handleShowModal: (e) ->
		$(e.currentTarget).find("input[type='text']").focus()
	triggerMathRender: ->
		@renderMath $(".math-input",@$el).val()
	triggerSubmit: (e) ->
		if e.keyCode is 13
			e.preventDefault()
			$(e.currentTarget).next().trigger "click"
			return false
	handleMathInput: (e) ->
		@triggerSubmit(e)
		@renderMath $(e.currentTarget).val()
	renderMath: (text) ->
		html = if $(".inline-format",@$el)[0].checked then "\\(" + text + "\\)" else "$$" + text + "$$"
		$("#MathOutput").html html
		MathJax.Hub.Queue(["Typeset",MathJax.Hub,"MathOutput"])

module.exports = BaseEditor
