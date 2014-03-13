(($) ->
	"use strict"
	readFileIntoDataUrl = (fileInfo) ->
		loader = $.Deferred()
		$.canvasResize fileInfo,
			width: 300
			height: 300
			crop: false
			quality: 80
			callback: (data, width, height) ->
				loader.resolve data
				return

		loader.promise()

	$.fn.cleanHtml = ->
		html = $(this).html()
		html and html.replace(/(<br>|\s|<div><br><\/div>|&nbsp;)*$/, "")

	$.fn.wysiwyg = (userOptions) ->
		editor = this
		selectedRange = undefined
		options = undefined
		toolbarBtnSelector = undefined
		updateToolbar = ->
			if options.activeToolbarClass
				$(options.toolbarSelector).find(toolbarBtnSelector).each ->
					commandArr = $(this).data(options.commandRole).split(" ")
					command = commandArr[0]

					# If the command has an argument and its value matches this button. == used for string/number comparison
					if commandArr.length > 1 and document.queryCommandEnabled(command) and document.queryCommandValue(command) is commandArr[1]
						$(this).addClass options.activeToolbarClass

					# Else if the command has no arguments and it is active
					else if commandArr.length is 1 and document.queryCommandEnabled(command) and document.queryCommandState(command)
						$(this).addClass options.activeToolbarClass

					# Else the command is not active
					else
						$(this).removeClass options.activeToolbarClass
					return

			return

		execCommand = (commandWithArgs, valueArg) ->
			commandArr = commandWithArgs.split(" ")
			command = commandArr.shift()
			args = commandArr.join(" ") + (valueArg or "")
			document.execCommand command, 0, args
			updateToolbar()
			return

		bindHotkeys = (hotKeys) ->
			$.each hotKeys, (hotkey, command) ->
				editor.keydown(hotkey, (e) ->
					if editor.attr("contenteditable") and editor.is(":visible")
						e.preventDefault()
						e.stopPropagation()
						if typeof command is "function"
							command this
						else
							execCommand command
					return
				).keyup hotkey, (e) ->
					if editor.attr("contenteditable") and editor.is(":visible")
						e.preventDefault()
						e.stopPropagation()
					return

				return

			return

		getCurrentRange = ->
			sel = window.getSelection()
			sel.getRangeAt 0  if sel.getRangeAt and sel.rangeCount

		saveSelection = ->
			selectedRange = getCurrentRange()
			return

		restoreSelection = ->
			selection = window.getSelection()
			if selectedRange
				try
					selection.removeAllRanges()
				catch ex
					document.body.createTextRange().select()
					document.selection.empty()
				selection.addRange selectedRange
			return

		insertFiles = (files) ->
			editor.focus()
			$.each files, (idx, fileInfo) ->
				if /^image\//.test(fileInfo.type)
					$.when(readFileIntoDataUrl(fileInfo)).done((dataUrl) ->
						execCommand "insertimage", dataUrl
						options.afterUpload()
						return
					).fail (e) ->
						options.fileUploadError "file-reader", e
						return

				else
					options.fileUploadError "unsupported-file-type", fileInfo.type
				return

			return

		markSelection = (input, color) ->
			restoreSelection()
			document.execCommand "hiliteColor", 0, color or "transparent"  if document.queryCommandSupported("hiliteColor")
			saveSelection()
			input.data options.selectionMarker, color
			return

		bindToolbar = (toolbar, options) ->
			toolbar.find(toolbarBtnSelector).click ->
				restoreSelection()
				editor.focus()
				execCommand $(this).data(options.commandRole)
				saveSelection()
				return

			toolbar.find("[data-toggle=modal],[data-toggle=dropdown]").click restoreSelection

			toolbar.find("input[type=text][data-" + options.commandRole + "]").next().on "click",->
				$input = $(@).prev()
				switch $input.data("format")
					when "latex"
						newValue = (if toolbar.find(".inline-format")[0].checked then ("\\(" + $input.val() + "\\)") else ("$$" + $input.val() + "$$"))
					when "url"
						newValue = $input.val()
						regx = new RegExp("https?://.+")
						if regx.test newValue
							$input.closest(".form-group").removeClass "has-error"
						else
							$input.closest(".form-group").addClass "has-error"
							return false
					else
						newValue = $input.val()

				$input.val("")
				restoreSelection()
				if newValue
					editor.focus()
					execCommand $input.data(options.commandRole), newValue
				saveSelection()
				$(".modal").modal "hide"

			# ugly but prevents fake double-calls due to selection restoration
			toolbar.find("input[type=text][data-" + options.commandRole + "]").on("focus", ->
				input = $(this)
				unless input.data(options.selectionMarker)
					markSelection input, options.selectionColor
					input.focus()
				return
			).on "blur", ->
				input = $(this)
				markSelection input, false  if input.data(options.selectionMarker)
				return

			toolbar.find("input[type=file][data-" + options.commandRole + "]").change ->
				restoreSelection()
				insertFiles @files  if @type is "file" and @files and @files.length > 0
				saveSelection()
				@value = ""
				return

			return

		initFileDrops = ->
			editor.on("dragenter dragover", false).on "drop", (e) ->
				dataTransfer = e.originalEvent.dataTransfer
				e.stopPropagation()
				e.preventDefault()
				insertFiles dataTransfer.files  if dataTransfer and dataTransfer.files and dataTransfer.files.length > 0
				return

			return

		options = $.extend(true, $.fn.wysiwyg.defaults, userOptions)
		toolbarBtnSelector = "a[data-" + options.commandRole + "],button[data-" + options.commandRole + "],input[type=button][data-" + options.commandRole + "]"
		bindHotkeys options.hotKeys
		initFileDrops()  if options.dragAndDropImages
		bindToolbar $(options.toolbarSelector), options
		editor.attr("contenteditable", true).on "mouseup keyup mouseout", ->
			saveSelection()
			updateToolbar()
			return

		$(window).bind "touchend", (e) ->
			isInside = (editor.is(e.target) or editor.has(e.target).length > 0)
			currentRange = getCurrentRange()
			clear = currentRange and (currentRange.startContainer is currentRange.endContainer and currentRange.startOffset is currentRange.endOffset)
			if not clear or isInside
				saveSelection()
				updateToolbar()
			return

		this

	$.fn.wysiwyg.defaults =
		hotKeys:
			"ctrl+b meta+b": "bold"
			"ctrl+i meta+i": "italic"
			"ctrl+u meta+u": "underline"
			"ctrl+z meta+z": "undo"
			"ctrl+y meta+y meta+shift+z": "redo"
			"ctrl+l meta+l": "justifyleft"
			"ctrl+r meta+r": "justifyright"
			"ctrl+e meta+e": "justifycenter"
			"ctrl+j meta+j": "justifyfull"
			"shift+tab": "outdent"
			tab: "indent"

		toolbarSelector: "[data-role=editor-toolbar]"
		commandRole: "edit"
		activeToolbarClass: "active"
		selectionMarker: "edit-focus-marker"
		selectionColor: "darkgrey"
		dragAndDropImages: true
		fileUploadError: (reason, detail) ->
			console.log "File upload error", reason, detail
			return

		afterUpload: ->
			console.log "Uploaded"
			return

	return
) window.jQuery
