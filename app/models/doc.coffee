class Doc extends Spine.Model
	@configure 'Doc', "_id",  'title', 'raw_content', "c_at", "u_at"
	@extend Spine.Model.Ajax

module.exports = Doc
