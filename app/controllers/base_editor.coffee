Notify = require("lib/utils/notify")
Doc = require("models/doc")
class BaseEditor extends Spine.Controller
	@include Notify
	events:
		"submit form": "onSubmit"
		"click .picBtn": "uploadPic"
		"change .scale-img": "scaleImg"
		"click .editor img": "selectImg"
		"dragstart .editor img": "handleDragStart"
		"dragend .editor img": "handleDragEnd"
		"blur .editor": "handleBlur"
	setup: ->
		$('a[title]').tooltip(container: 'body')
		@$editor = $('#editor_' + @editor_id)
		@$editor.wysiwyg
			fileUploadError: (reason, detail) =>
				@flash reason + detail
			afterUpload: =>
				$("img",@$editor).attr "draggable",true
				$(".picture_control",@$el).show()
		@$editor.on "drop", @handleDrop
		@$editor.on "dragover", @handleDragOver
	uploadPic: (e) ->
		target_id = $(e.currentTarget).attr "id"
		$("input[data-target='#{target_id}']").trigger "click"
	selectImg: (e) ->
		$img = $(e.currentTarget)
		$img.addClass("active").siblings().removeClass("active")
		rate = parseFloat $img.width()/$img[0].naturalWidth
		$(".scale-img",@$el).val rate
	scaleImg: (e) ->
		$target = $(e.currentTarget)
		rate = $target.val()
		$target.prev().find(".num").text rate
		$img = $("img.active",@$editor)
		if !$img.length
			$img = $("img:eq(0)",@$editor)
		unless !$img.length
			$img.width $img[0].naturalWidth * rate
	handleBlur: (e) ->
		$imgs = $(e.currentTarget).find("img")
		$imgs.removeClass "active"
		if $imgs.length is 0
			$(".picture_control",@$el).hide()
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
	onSubmit: (e) ->
		e.preventDefault()
		$form = $(e.currentTarget)
		html = @$editor.cleanHtml()
		if html is ""
			@flash "正文内容不允许为空","danger"
			@$editor.focus()
			return false
		else
			formObj = $form.serializeObject()
			data = $.extend {},formObj,raw_content: html
			$(".brand").addClass "loading"
			Doc.create data, done: ->
				$(".brand").removeClass "loading"
				Spine.Route.navigate("/doc/" + Doc.last()._id,true)

module.exports = BaseEditor
