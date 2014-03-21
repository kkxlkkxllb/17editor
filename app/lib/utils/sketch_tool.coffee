Sketch = require("lib/utils/sketch")
Color = require("lib/utils/color")
Kinetic = require("lib/utils/kinetic")

ColorControl =
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

KineticImage =
	addAnchor: (group,x,y) ->
		stage = group.getStage()
		layer = group.getLayer()
		img = new Image()
		img.src = "/assets/images/resize.png"
		img.onload = ->
			anchor = new Kinetic.Image
				x:  (x - 8)
				y: (y - 8)
				image: img
				name: "anchor"
				draggable: true
				dragBoundFunc: (pos) ->
					max_x = group.x() + x - 8
					max_y = group.y() + y - 8
					if pos.x > max_x
						nx = max_x
					else if pos.x < group.x()
						nx = group.x()
					else
						nx = pos.x
					ny = (pos.x - group.x())*y/x + group.y()
					if ny > max_y
						ny = max_y
					else if ny < group.y()
						ny = group.y()
					x: nx
					y: ny

			group.add anchor
			tatget = group.find(".image")[0]
			anchor.on "dragmove", (e) ->
				dw = e.offsetX - group.x()
				dh = (dw/x)*y
				if dw > 0 and dw <= x
					tatget.setSize
						width: dw
						height: dh
					group.getLayer().draw()

			anchor.on "mousedown touchstart", (e) ->
				group.setDraggable(false)
			anchor.on "dragend", ->
				group.setDraggable(true)

SketchTool =
	initSketch: (container) ->
		self = this
		$container = $("#" + container)
		ColorControl.initColors()
		# canvas 1
		@stage = new Kinetic.Stage
			container: container
			width: 600
			height: 300

		$container.append require("views/widgets/pointer")()
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
			mouseout: ->
				$(".pointer",$container).addClass "hide"
			mouseover: ->
				$(".pointer",$container).removeClass "hide"
			touchstart: ->
				@fillStyle = @strokeStyle = self.eraserStyle || $(".color-control-current").data("color")
				@lineCap = 'round'
				@lineJoin = 'round'
				@lineWidth = self.sketchSize || 5
			touchmove: ->
				touch = @touches[0]
				transform = "translateX(" + touch.ox + "px) translateY(" + touch.oy + "px)"
				$(".pointer",$container).css
					"transform": transform
					"-webkit-transform": transform
					"-ms-transform": transform
				if @dragging
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

			group = new Kinetic.Group
				draggable: true
			layer = new Kinetic.Layer()
			img = new Kinetic.Image
				name: "image"
			group.add img
			layer.add group
			self.stage.add layer

			fr = new FileReader()
			fr.readAsDataURL(files[0])
			fr.onload = (ev) ->
				imgObj = new Image()
				imgObj.src = ev.target.result
				img.setImage imgObj
				layer.draw()
				$(self.stage.getContent()).css "z-index": 30
				KineticImage.addAnchor group, img.width(), img.height()

			img.on "mouseover", ->
				$container.css "cursor": "move"
			img.on "mouseout", ->
				$container.css "cursor": "default"
			# write to sketch
			img.on "dblclick", ->
				@getParent().find(".anchor")[0].destroy()
				@getLayer().draw()
				self.setSketchData @getCanvas().toDataURL(),false
				@getLayer().destroy()
				@destroy()
				if self.stage.getChildren().length is 0
					$(self.stage.getContent()).css "z-index": 1
					$container.css "cursor": "crosshair"
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
		params =
			width: size
			height: size
			marginLeft: (-size/2)
			marginTop: (-size/2)
		$(e.currentTarget).next().css params
		$(".pointer").css(params).toggleClass "invisible", size < 10
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
