Sketch = require("lib/utils/sketch")
Color = require("lib/utils/color")

SketchTool =
	initColors: ->
		for val in [0.75, 0.5, 0.25]
			colors = []
			if val is 0.25
				colors.push Color._rgba(0, 0, 0, 1).toString()
			if val is 0.5
				colors.push Color._rgba(150, 150, 150, 1).toString()
			if val is 0.75
				colors.push Color._rgba(255, 255, 255, 1).toString()
			for i in [0..330] by 30
				colors.push Color._hsl2Rgba(Color._hsl(i-60, 1, val)).toString()
			$(".color-control-rainbows").append require("views/items/color")(colors: colors)

	initSketch: ($container) ->
		self = this
		@initColors()
		@sketch = Sketch.create
			fullscreen: false
			autoclear: false
			autostart: false
			width: 600
			height: 300
			container: $container[0]
			setup: ->
				if data = self.getLocalStorage()
					self.setDataWith data, @
			mouseup: ->
				 self.setLocalStorage @canvas.toDataURL("image/png")
			# window resize bug hack
			resize: ->
				if data = self.getLocalStorage()
					self.setDataWith data, @
			touchmove: ->
				if @dragging
					touch = @touches[0]
					@lineCap = 'round'
					@lineJoin = 'round'
					@lineWidth = self.sketchSize || 5
					@fillStyle = @strokeStyle = self.strokeStyle || "#333"
					@beginPath()
					@moveTo touch.ox, touch.oy
					@lineTo touch.x, touch.y
					@stroke()
		$(@sketch.canvas).on "dragover dragenter drop", (e) ->
			e.stopPropagation()
			e.preventDefault()
		$(@sketch.canvas).on "drop", (e) ->
			e = e.originalEvent
			files = e.dataTransfer.files
			fr = new FileReader()
			fr.readAsDataURL(files[0])
			fr.onload = (ev) ->
				self.setSketchData ev.target.result
	setLocalStorage: (data) ->
		window["localStorage"].setItem "sketch-data", data
	getLocalStorage: ->
		window["localStorage"].getItem "sketch-data"
	getSketchData: ->
		@sketch.canvas.toDataURL("image/png")
	setDataWith: (data,ctx) ->
		img = @currentSketchImg || new Image()
		img.onload = ->
			ctx.drawImage(@, 0, 0)
		img.src = data
	setSketchData: (data) ->
		@sketch.clear()
		if data
			@setDataWith data, @sketch
			@setLocalStorage data
	setLineWidth: (e) ->
		@sketchSize = size = $(e.currentTarget).val()
		$(e.currentTarget).next().css
			width: size
			height: size
			marginLeft: (-size/2)
			marginTop: (-size/2)
			borderRadius: size + "px"
	setColor: (e) ->
		color = $(e.currentTarget).data("color")
		$(".color-control-current").css("color": color).data("color",color)
		$(".sketch_control .pencil").trigger "click"
	clearSketch: (e) ->
		@sketch.clear()
		window["localStorage"].removeItem "sketch-data"
	downloadSketch: (e) ->
		data = @getSketchData().replace("image/png", "image/octet-stream")
		window.location.href = data
	setPencil: (e) ->
		@sketch.globalCompositeOperation = "source-over"
		@strokeStyle = $(".color-control-current").data("color")
		$(e.currentTarget).addClass("active").siblings().removeClass "active"
	setEraser: (e) ->
		@sketch.globalCompositeOperation = "copy"
		@strokeStyle = "transparent"
		$(e.currentTarget).addClass("active").siblings().removeClass "active"


module?.exports = SketchTool
