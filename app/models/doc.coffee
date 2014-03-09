class Doc extends Spine.Model
	@configure 'Doc', "id",  'title', 'raw_content', "u_at"
	@extend Spine.Model.Ajax

	@fromJSON: (json) ->
		super([].concat json.data)

module.exports = Doc

# ... 2 <= arguments.length ? __slice.call(arguments, 1) : []
