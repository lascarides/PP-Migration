class Format

	attr_accessor :id, :title, :start_year, :end_year, :short_description, :essay, :api_domain

	def self.find(dnz_id)
		DigitalNZ.find(dnz_id)		
	end

	def self.search_results(search_params)
		scope = self.dnz_search_scope
		if search_params[:start_date] or search_params[:end_date]
			# FIXME: Hardcoded boundary dates
			start_date 	= search_params[:start_date] || self.start_year
			end_date 	= search_params[:end_date] || self.end_year
			scope += "&and[year]=[#{start_date}+TO+#{end_date}]"
		end
		if search_params['title-region']
			search_params['title-region'].split(',').each { |title_symbol|
				# FIXME: Hardcoded to newspapers
				item = Publication.find(title_symbol)
				scope += "&or[collection][]="
				scope += CGI.escape( item[:title] )
			}
		end
		if search_params[:sort]
			scope += "&sort=" + search_params[:sort]
		end
		if search_params[:direction]
			scope += "&direction=" + search_params[:direction]
		end
		DigitalNZ.search_results(search_params[:query], scope)		
	end

	def self.dates_for(publication_id)
		v = VeridianAPI.new
		v.get_dates(publication_id)
	end

	def self.get_issue(publication_id, date)
		v = VeridianAPI.new
		v.get_document_content(publication_id + date.strftime("%Y%m%d"))
	end

	def self.start_year
		1839
	end

	def self.end_year
		1945
	end

	def self.collections(search_term)
		DigitalNZ.collections(self.dnz_search_scope)		
	end

	def self.dnz_search_scope
		''
	end

	def self.description
		"<strong>Papers Past</strong> contains more than three million pages of digitised New Zealand newspapers and periodicals. The collection covers the years 1839 to 1945 and includes 83 publications from all regions of New Zealand."
	end

end