class Newspaper < NLNZObject

	require 'nokogiri'
	require 'open-uri'

	def self.find(id)

		if id =~ /[A-Z]+\d{8}\-\d/
			result = DigitalNZ.search_results(id.gsub('-', '.'))
			id = result['search']['results'].first['id'].to_s
		end

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

	def self.front_pages
		year = Time.now.strftime("%Y").to_i - 100
		date_string = Time.now.strftime("%m.%d")
		article = Nokogiri::HTML(open("http://paperspast.natlib.govt.nz/cgi-bin/paperspast?a=d&cl=CL2.#{year}.#{date_string}&sp=&e=-------10--1----0--"))
		article.css("ul.tri-list a").collect { |front_page| 
			front_page.to_s.gsub!(/^.*d=([A-Z]+)\d\d\d\d.*$/, '\1')
		}
	end

	def self.outline(issue, page = :all)
		contents = Nokogiri::HTML(open("http://paperspast.natlib.govt.nz/cgi-bin/paperspast?a=d&d=#{issue}"))
		# FIXME does not work yet
		contents = contents.css("#contentslist-wrap b", "#contentslist-wrap a")
		current_page = "Page 1"
		output = {}
		contents.each do |content|
			if content.to_s =~ /<b>/ 
				current_page = content.content().to_s.strip
			else
				output[current_page] ||= []
				output[current_page] << {
					:href => '/newspapers/' + content.attribute('href').to_s.gsub(/^.*d=(.*)\&e=.*$/, '\1').gsub('.', '-'),
					:label => content.content()
				}
			end
		end
		output
	end

	def self.areas(issue_page)
		contents = Nokogiri::HTML(open("http://paperspast.natlib.govt.nz/cgi-bin/paperspast?a=d&d=#{issue_page}"))
		contents.css(".veridianlogicalsectionarea").collect do |content|
			{
				:style => content.attribute('style').to_s,
				:href => '/newspapers/' + content.attribute('href').to_s.gsub(/^.*d=(.*)\&e=.*$/, '\1').gsub('.', '-')
			}
		end
	end

	# UNCOMMENT WHEN GETTING ADV SEARCH TO READ FROM PP DIRECTLY
	# Also, doesn't work yet.

	# def self.search_results(search_params)
	# 	query = "http://paperspast.natlib.govt.nz/cgi-bin/paperspast?a=q&hs=1&r=1&results=1&t=0&txq=#{search_params[:query]}&sf=&ssnip=on&"
	# 	search_params[:papers].split(',').each do |paper|
	# 		query += "pbq=#{paper}&"
	# 	end
	# 	result_page = Nokogiri::HTML(open(query))
	# 	# dafdq=02&
	# 	# dafmq=02&
	# 	# dafyq=1846&
	# 	# datdq=06&
	# 	# datmq=05&
	# 	# datyq=1874&
	# 	# tyq=ARTICLE&
	# 	# tyq=ADVERTISEMENT&
	# 	# tyq=ILLUSTRATION&
	# 	# o=10&
	# end

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

	def self.titles_for_date(today)
		date_formatted = today.strftime("%Y.%0m.%0d")
		url = "http://paperspast.natlib.govt.nz/cgi-bin/paperspast?a=d&cl=CL2.#{date_formatted}&sp="
		page = Nokogiri::HTML( open(url) )
		page.css("#browse-results .tri-list li a").collect { |item| 
			item.content
		}
	end

	def self.num_pages_for_date(today, code)
		date_formatted = today.strftime("%Y%0m%0d")
		url = "http://paperspast.natlib.govt.nz/cgi-bin/paperspast?a=d&d=#{code}#{date_formatted}"
		page = Nokogiri::HTML( open(url) )
		page.css("#contents-pageslist li").count
	end

	def self.page_image_url(today, code, page, scale)
		date_formatted = today.strftime("%Y%0m%0d")
		url = "http://paperspast.natlib.govt.nz/cgi-bin/imageserver/imageserver.pl?oid=#{code}#{date_formatted}.1.#{page}&scale=#{scale}&color=32&ext=gif&key="
	end

	def self.description
		"<strong>Papers Past</strong> contains more than three million pages of digitised New Zealand newspapers and periodicals. The collection covers the years 1839 to 1945 and includes 83 publications from all regions of New Zealand."
	end


end