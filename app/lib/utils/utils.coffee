Utils =
	flash: (msg,type = "warning",$container) ->
		$container = $container || $("#flash_message")
		$container.prepend require('views/widgets/flash')(msg: msg)
		$alert = $(".alert:eq(0)",$container)
		$alert.addClass "alert-#{type}"
		$alert.show()
		fuc = ->
			$alert.remove()
		setTimeout fuc,10000
		false

module?.exports = Utils
