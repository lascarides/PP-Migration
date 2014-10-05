class NLNZObject

	def self.find(dnz_id)
		DigitalNZ.find(dnz_id)		
	end

	def self.search_results(search_params)
		scope = self.dnz_search_scope
		if search_params[:start_date] or search_params[:end_date]
			# FIXME: Hardcoded boundary dates
			start_date 	= search_params[:start_date] || 1839
			end_date 	= search_params[:end_date] || 1945
			scope += "&and[year]=[#{start_date}+TO+#{end_date}]"
		end
		if search_params[:titles]
			search_params[:titles].split(',').each { |title_symbol|
				# FIXME: Hardcoded to newspapers
				item = NewspaperTitle.find(title_symbol)
				scope += "&or[collection][]="
				scope += CGI.escape( item[:title] )
			}
		end
		DigitalNZ.search_results(search_params[:query], scope)		
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