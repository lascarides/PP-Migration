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

	def date
		@year = params[:year]
		if @year =~ /^\d\d\d\ds$/
			@year = nil
			@decade = params[:year]
		elsif @year =~ /^\d\d\d\d$/
			@decade = @year.gsub(/^(\d\d\d)\d$/, '\1') + "0s"
			@year = @year.to_i
		else
			@decade = nil
		end
		@month = params[:month].to_i
		@day = params[:day].to_i
		if @day > 0
			@today = Date.new(@year, @month, @day)
			@titles = Newspaper.titles_for_date(@today)
		end
	end

	def date_alt
	end

	def region
		if params[:region]
			@titles = NewspaperTitle.info.collect{ |ntk, ntv| 
				if ntv[:region].parameterize == params[:region]
					ntv
				end
			}.uniq.compact
			@region = @titles.first[:region]
			@page_title = "#{@region}-based newspapers"
		else
			@page_title = "Newspapers by region"
		end
	end

end
