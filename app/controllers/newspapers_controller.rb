class NewspapersController < FormatViewerController

	def title
		if not params[:id].nil?
			@item 	= NewspaperTitle.find(params[:id])
			@code 	= NewspaperTitle.code(params[:id])
			@year 	= @item[:date_year] = params[:year].to_i
			@month 	= @item[:date_month] = params[:month].to_i
			@day 	= @item[:date_day] = params[:day].to_i
			if @day > 0
				@today = @item[:date] = Date.new(@year, @month, @day)
				@num_pages = Newspaper.num_pages_for_date(@today, @code)
				if not params[:page].nil?
					@page = @item[:page_number]= params[:page].to_i
					render :action => 'page'
				else
					render :action => 'issue'
				end
			end
		end
	end

end
