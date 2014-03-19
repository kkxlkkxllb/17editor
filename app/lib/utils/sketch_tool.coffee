Sketch = require("lib/utils/sketch")
Color = require("lib/utils/color")
Kinetic = require("lib/utils/kinetic")

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

	initSketch: (container) ->
		self = this
		$container = $("#" + container)
		@initColors()

		# canvas 1
		@stage = new Kinetic.Stage
			container: container
			width: 600
			height: 300

		# canvas 2
		@sketch = Sketch.create
			fullscreen: false
			autoclear: false
			autostart: false
			width: 600
			height: 300
			container: $container[0]
			setup: ->
				$(@canvas).css
					"position": "absolute"
					"top": 0
					"left": 0
					"z-index": 10
				if data = self.getLocalStorage()
					self.setDataWith data, @
			mouseup: ->
				 self.setLocalStorage @canvas.toDataURL("image/png")
			touchstart: ->
				@fillStyle = @strokeStyle = self.eraserStyle || $(".color-control-current").data("color")
				@lineCap = 'round'
				@lineJoin = 'round'
				@lineWidth = self.sketchSize || 5
			touchmove: ->
				if @dragging
					touch = @touches[0]
					@beginPath()
					@moveTo touch.ox, touch.oy
					@lineTo touch.x, touch.y
					@closePath()
					@stroke()

		# canvas 3
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
					"z-index": 20
			touchstart: ->
				@start_x = @touches[0].x
				@start_y = @touches[0].y
				@lineCap = 'round'
				@lineJoin = 'round'
				@fillStyle = @strokeStyle = $(".color-control-current").data("color")
				@lineWidth = self.sketchSize || 5
			# save to really canvas
			touchend: ->
				self.sketch.drawImage @canvas,0,0
				self.setLocalStorage self.sketch.canvas.toDataURL("image/png")
			draw: ->
				if @dragging
					touch = @touches[0]
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

		$container.on "dragover dragenter drop", (e) ->
			e.stopPropagation()
			e.preventDefault()
		$container.on "drop", (e) ->
			e = e.originalEvent
			files = e.dataTransfer.files
			fr = new FileReader()
			fr.readAsDataURL(files[0])
			img = new Kinetic.Image
				draggable: true
			img.on "mouseover", ->
				$container.css "cursor": "move"
			img.on "mouseout", ->
				$container.css "cursor": "default"
			img.on "mousemove", (e) ->
				ox = @width() + @x() - e.offsetX
				oy = @height() + @y() - e.offsetY
				if  ox < 10 and oy < 10
					cursor = "nwse-resize"
					@draggable(false)
				else
					cursor = "move"
					@draggable(true)
				$container.css "cursor": cursor

			# write to sketch
			img.on "dblclick", ->
				self.setSketchData @getCanvas().toDataURL(),false
				@getLayer().destroy()
				@destroy()
				if self.stage.getChildren().length is 0
					$(self.stage.getContent()).css "z-index": 1
					$container.css "cursor": "crosshair"
			layer = new Kinetic.Layer()
			layer.add img
			self.stage.add layer
			fr.onload = (ev) ->
				imgObj = new Image()
				imgObj.src = ev.target.result
				img.setImage imgObj
				layer.draw()
				$(self.stage.getContent()).css "z-index": 30

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
