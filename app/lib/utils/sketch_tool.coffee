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
				@lineCap = 'round'
				@lineJoin = 'round'
			mouseup: ->
				 self.setLocalStorage @canvas.toDataURL("image/png")
			# window resize bug hack
			resize: ->
				if data = self.getLocalStorage()
					self.setDataWith data, @
			touchstart: ->
				@fillStyle = @strokeStyle = self.eraserStyle || $(".color-control-current").data("color")
			touchmove: ->
				if @dragging
					touch = @touches[0]
					@lineWidth = self.sketchSize || 5
					@beginPath()
					@moveTo touch.ox, touch.oy
					@lineTo touch.x, touch.y
					@closePath()
					@stroke()

		@tmp_sketch = Sketch.create
			fullscreen: false
			autoclear: true
			autostart: true
			width: 600
			height: 300
			container: $container[0]
			setup: ->
				$(@canvas).hide().css
					"position": "absolute"
					"top": 0
					"left": 0
				@lineCap = 'round'
				@lineJoin = 'round'
			touchstart: ->
				@start_x = @touches[0].x
				@start_y = @touches[0].y
				@fillStyle = @strokeStyle = $(".color-control-current").data("color")
			# save to really canvas
			touchend: ->
				self.sketch.drawImage @canvas,0,0
				self.setLocalStorage self.sketch.canvas.toDataURL("image/png")
			draw: ->
				if @dragging
					touch = @touches[0]
					@lineWidth = self.sketchSize || 5
					switch @graph
						when "line"
							@beginPath()
							@moveTo(@start_x, @start_y)
							@lineTo(touch.x, touch.y)
							@stroke()
							@closePath()
						when "rect"
							x = min(touch.x, @start_x)
							y = min(touch.y, @start_y)
							width = abs(touch.x - @start_x)
							height = abs(touch.y - @start_y)
							@strokeRect(x, y, width, height)
						when "circle"
							x = (touch.x + @start_x)/2
							y = (touch.y + @start_y)/2
							radius = max(abs(touch.x - @start_x),abs(touch.y - @start_y))/2
							@beginPath()
							@arc(x,y,radius,0,TWO_PI,false)
							@stroke()
							@closePath()

		# drag & drop image from local
		$(@sketch.canvas).on "dragover dragenter drop", (e) ->
			e.stopPropagation()
			e.preventDefault()
		$(@tmp_sketch.canvas).on "dragover dragenter drop", (e) ->
			e.stopPropagation()
			e.preventDefault()
		$(@sketch.canvas).on "drop", (e) ->
			e = e.originalEvent
			files = e.dataTransfer.files
			fr = new FileReader()
			fr.readAsDataURL(files[0])
			fr.onload = (ev) ->
				self.setSketchData ev.target.result, false
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
	setSketchData: (data, clear = true) ->
		if clear
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
	clearSketch: (e) ->
		@sketch.clear()
		window["localStorage"].removeItem "sketch-data"
	downloadSketch: (e) ->
		data = @getSketchData().replace("image/png", "image/octet-stream")
		window.location.href = data

	setEraser: (e) ->
		$(@tmp_sketch.canvas).hide()
		@sketch.globalCompositeOperation = "copy"
		@eraserStyle = "transparent"
		$(e.currentTarget).addClass("active").siblings().removeClass "active"
	commonDrawMode: (e) ->
		@sketch.globalCompositeOperation = "source-over"
		@eraserStyle = false
		$(e.currentTarget).addClass("active").siblings().removeClass "active"
	setPencil: (e) ->
		$(@tmp_sketch.canvas).hide()
		@commonDrawMode(e)
	setLine: (e) ->
		$(@tmp_sketch.canvas).show()
		@commonDrawMode(e)
		@tmp_sketch.graph = "line"
	setRect: (e) ->
		$(@tmp_sketch.canvas).show()
		@commonDrawMode(e)
		@tmp_sketch.graph = "rect"
	setCircle: (e) ->
		$(@tmp_sketch.canvas).show()
		@commonDrawMode(e)
		@tmp_sketch.graph = "circle"


module?.exports = SketchTool
