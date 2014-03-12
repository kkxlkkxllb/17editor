class Doc extends Spine.Model
	@configure 'Doc', "id",  'title', 'raw_content', "u_at"
	@extend Spine.Model.Ajax

	@fromJSON: (json) ->
		if json.status is 0
			super([].concat json.data)
		else
			@trigger "serverError",json.msg
			super([])

module.exports = Doc

# ... 2 <= arguments.length ? __slice.call(arguments, 1) : []
