class ParliamentaryPaper < NLNZObject

	def self.find(id)
		result = DigitalNZ.find(id)
		record = {}
		record[:title] = result['title']
		record[:newspaper] = 'A to Js'
		record[:date] = result['display_date']
		record[:original] = result['landing_url']
		article = Nokogiri::HTML(open(result['landing_url']))
		record[:images] = article.css(".veridianimagecontainerdiv img").collect { |image| 
			image.to_s.gsub!('src="/', 'src="http://atojs.natlib.govt.nz/')
		}
		article = Nokogiri::HTML(open(result['landing_url'] + '&st=1'))
		record[:fulltext] = article.css("#ocr-nav .inner-contentwrap")
		record
	end

	def self.dnz_search_scope
		'&and[primary_collection][]=AtoJsOnline'
	end

end