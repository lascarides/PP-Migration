class Periodical < NLNZObject

	def self.dnz_search_scope
		'&or[primary_collection][]=Te+Ao+Hou&or[primary_collection][]=Transactions+and+Proceedings+of+the+Royal+Society+of+New+Zealand+1868-1961'
	end

	def self.description
		"<strong>Papers Past</strong> contains dozens of fully-digitised magazines and journals from the 19th century to the present day on a wide variety of topics."
	end

	def self.find(id)

		if id =~ /[A-Z]+\d{8}\-\d/
			result = DigitalNZ.search_results(id.gsub('-', '.'))
			id = result['search']['results'].first['id'].to_s
		end

		result = DigitalNZ.find(id)
		record = {}
		record[:title] 			= result['title']
		record[:collection] 	= result['collection'].first
		this_date = Date.parse(result['date'].first)  
		record[:date] 			= this_date
		record[:date_year] 		= this_date.year
		record[:date_day] 		= this_date.day
		record[:date_month] 	= this_date.month
		record[:fulltext] 		= result['fulltext']
		record[:original] 		= result['landing_url']
		if result['large_thumbnail_url'].nil?
			article = Nokogiri::HTML(open(result['landing_url']))
			record[:images] = article.css("a.figure img").collect { |image| 
				image = 'http://rsnz.natlib.govt.nz' + image.attribute('src').to_s
				image.gsub!('/thumbnails', '')
				image.gsub!('02.gif', '01.gif')
			}
			record[:fulltext] = article.css(".normal").collect { |text|
				text.to_s
			}.join
		else
			record[:images] 		= [result['large_thumbnail_url']]
		end
		record[:original] 		= result['landing_url']
		record
	end

end