class ParliamentaryPaper < NLNZObject

	def self.find(id)
		result = DigitalNZ.find(id)
		record = {}
		record[:title] 			= result['title']
		record[:collection] 	= 'A to Js'
		record[:parliamentary_session] 	= result['collection'].collect{|c| c.gsub(/^.*(Session .*)$/, '\1') if c =~ /Session/}.compact.first
		record[:date] 			= result['display_date']
		record[:date_year] 		= result['display_date']
		record[:original] 		= result['landing_url']
		article = Nokogiri::HTML(open(result['landing_url']))
		record[:images] = article.css(".veridianimagecontainerdiv img").collect { |image| 
			"http://atojs.natlib.govt.nz" + image.attribute('src')
		}
		article = Nokogiri::HTML(open(result['landing_url'] + '&st=1'))
		record[:fulltext] = article.css("#ocr-nav .inner-contentwrap").to_s
		record
	end

	def self.dnz_search_scope
		'&and[primary_collection][]=AtoJsOnline'
	end

	def self.description
		"<strong>Papers Past</strong> contains a collection of digitised volumes of the Appendices to the Journals of the House of Representatives and the Votes and Proceedings of the House of Representatives. The collection currently covers the years 1854 to 1950."
	end

end