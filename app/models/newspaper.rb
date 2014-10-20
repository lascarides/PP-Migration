class Newspaper < Format

	require 'nokogiri'
	require 'open-uri'

	def self.find(id)

		id.gsub! '-', '.'
		v = VeridianAPI.new
		v.get_logical_section_content(id)
		# record[:title] 			= title[0]
		# record[:collection] 	= title[1]
		# record[:date] 			= Date.parse(result['date'].first)
		# record[:date_year] 		= record[:date].year
		# record[:date_day] 		= record[:date].day
		# record[:date_month] 	= record[:date].month
		# record[:fulltext] 		= result['fulltext']
		# record[:original] 		= nil
		# article = Nokogiri::HTML(open(result['landing_url']))
		# record[:images] = article.css(".veridianimagecontainerdiv img").collect { |image| 
		# 	"http://paperspast.natlib.govt.nz" + image.attribute('src').to_s
		# }
		# record
	end

	def self.search_results(search_params)
		v = VeridianAPI.new
		v.search_logical_sections(search_params['query'])
	end

	def self.front_pages
		v = VeridianAPI.new
		t = Time.now - 100.years
		v.search_documents(:start_date => t.strftime('%Y%m%d'), :end_date => (t + 5.days).strftime('%Y%m%d'))
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

	def self.dnz_search_scope
		'&and[primary_collection][]=Papers+Past'
	end

	def self.page_image_url(today, code, page, scale)
		date_formatted = today.strftime("%Y%0m%0d")
		url = "http://paperspast.natlib.govt.nz/cgi-bin/imageserver/imageserver.pl?oid=#{code}#{date_formatted}.1.#{page}&scale=#{scale}&color=32&ext=gif&key="
	end

	def self.description
		"<strong>Papers Past</strong> contains more than three million pages of digitised New Zealand newspapers and periodicals. The collection covers the years 1839 to 1945 and includes 83 publications from all regions of New Zealand."
	end

	def self.year_data_for_bar_chart
		year_data = {}
		JSON.load(open("app/views/about/charts.json")).collect do |paper|
			paper['articles'].collect do |year, counter|
				year_data[year] ||= 0
				year_data[year] += counter
			end
		end
		year_data
	end


end