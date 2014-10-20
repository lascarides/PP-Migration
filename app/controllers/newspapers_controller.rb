class NewspapersController < FormatViewerController

	def title
		if not params[:id].nil?
			@publication_id = Publication.code(params[:id])
			@item 	= Publication.find(params[:id])
			if not params[:page].nil?
				params[:page].to_i
				render :action => 'page'
			elsif not params[:day].nil?
				@issue = Newspaper.get_issue(
					@publication_id, Date.new(
						params[:year].to_i, 
						params[:month].to_i, 
						params[:day].to_i
					) 
				)
				render :action => 'issue'
			else
				@dates = Newspaper.dates_for(@publication_id)
				@year  = params[:year] || @dates.first.year
			end
		end
	end

end