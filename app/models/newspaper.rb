class Newspaper < NLNZObject

	def self.find(id)
		result = DigitalNZ.find(id)
		record = {}
		title = result['title'].gsub(/^(.*)\(([^(]+),(.*)\)/, '\1**\2**\3').split("**")
		record[:title] = title[0]
		record[:newspaper] = title[1]
		record[:date] = title[2]
		record[:date_year] = title[2].split(' ')[2]
		record[:date_day] = title[2].split(' ')[0]
		record[:date_month] = title[2].split(' ')[1]
		record[:fulltext] = result['fulltext']
		record[:original] = result['landing_url']
		article = Nokogiri::HTML(open(result['landing_url']))
		record[:images] = article.css(".veridianimagecontainerdiv img").collect { |image| 
			image.to_s.gsub!('src="/', 'src="http://paperspast.natlib.govt.nz/')
		}
		record
	end

	def self.dnz_search_scope
		'&and[primary_collection][]=Papers+Past'
	end

	def self.collections
		{
			'Evening Post' =>  3673033,
			'Wanganui Chronicle' =>  1163217,
			'Otago Daily Times' =>  1151147,
			'Hawera & Normanby Star' =>  1075326,
			'Marlborough Express' =>  1036164,
			'Auckland Star' =>  1005149,
			'Colonist' =>  999871,
			'Poverty Bay Herald' =>  963395,
			'Grey River Argus' =>  890904,
			'Thames Star' =>  869633,
			'Ashburton Guardian' =>  830871,
			'Star' =>  819678,
			'Wanganui Herald' =>  784091,
			'Nelson Evening Mail' =>  693164,
			'Taranaki Herald' =>  677704,
			'Feilding Star' =>  650958,
			'Otago Witness' =>  603646,
			'Wairarapa Daily Times' =>  575596,
			'West Coast Times' =>  534690,
			'Hawke\'s Bay Herald' =>  445395,
			'Southland Times' =>  418609,
			'North Otago Times' =>  417958,
			'Timaru Herald' =>  406184,
			'Bay Of Plenty Times' =>  371855,
			'Daily Telegraph' =>  332729,
			'Northern Advocate' =>  327513,
			'Daily Southern Cross' =>  279640,
			'Bush Advocate' =>  231016,
			'Bruce Herald' =>  221282,
			'Manawatu Standard' =>  210799,
			'Ellesmere Guardian' =>  207019,
			'Tuapeka Times' =>  183923,
			'NZ Truth' =>  169139,
			'Ohinemuri Gazette' =>  168704,
			'Observer' =>  167452,
			'Akaroa Mail and Banks Peninsula Advertiser' =>  163792,
			'Manawatu Times' =>  140493,
			'Wellington Independent' =>  135064,
			'New Zealand Tablet' =>  134145,
			'Inangahua Times' =>  120497,
			'Waikato Times' =>  93891,
			'Mataura Ensign' =>  90429,
			'Clutha Leader' =>  87851,
			'Rodney and Otamatea Times, Waitemata and Kaipara Gazette' =>  87830,
			'Nelson Examiner and New Zealand Chronicle' =>  82989,
			'Manawatu Herald' =>  80758,
			'Otautau Standard and Wallace County Chronicle' =>  63907,
			'Lyttelton Times' =>  35715,
			'Te Aroha News' =>  34064,
			'New Zealand Free Lance' =>  30376,
			'Hutt News' =>  18776,
			'Kaipara and Waitemata Echo' =>  17861,
			'New Zealand Spectator and Cook\'s Strait Guardian' =>  17774,
			'Waiapu Church Gazette' =>  13732,
			'New Zealander' =>  11954,
			'Oxford Observer' =>  11708,
			'Waimate Daily Advertiser' =>  6941,
			'New Zealand Gazette and Wellington Spectator' =>  6576,
			'Progress' =>  6309,
			'New Zealand Illustrated Magazine' =>  6058,
			'Hawke\'s Bay Weekly Times' =>  2909,
			'New Zealand Colonist and Port Nicholson Advertiser' =>  1818,
			'Kai Tiaki' =>  1603,
			'Fair Play' =>  1412,
			'Waiapu Church Times' =>  471,
			'New Zealand Advertiser and Bay of Islands Gazette' =>  297,
			'Albertland Gazette' => 131
		}.to_a
	end

end