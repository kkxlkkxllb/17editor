require('json2ify')
require('es5-shimify')
require('jqueryify')

require('spine')
require('spine/lib/local')
require('spine/lib/ajax')
require('spine/lib/manager')
require('spine/lib/route')

require("lib/bootstrap.min")

require("lib/jquery/jquery-dateFormat")
require("lib/jquery/jquery.serializeObject")
require("lib/jquery/jquery.hotkeys")
require("lib/jquery/bootstrap-wysiwyg")

require("lib/utils/drawingboard")
require("lib/utils/drawingboard_extend")

require("lib/sound/speech")


# 跨域请求带上cookie等凭证
$.ajaxSetup
	xhrFields:
		withCredentials: true
	crossDomain: true
