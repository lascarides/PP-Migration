class NewspapersController < FormatViewerController

	def title
		@title 	= NewspaperTitle.find(params[:id])
		@code 	= NewspaperTitle.code(params[:id])
		@year 	= params[:year].to_i
		@month 	= params[:month].to_i
		@day 	= params[:day].to_i
		if @day > 0
			@today = Date.new(@year, @month, @day)
			@num_pages = Newspaper.num_pages_for_date(@today, @code)
			render :action => 'page'
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
