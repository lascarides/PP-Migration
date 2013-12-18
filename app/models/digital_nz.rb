class DigitalNZ

	DNZ_API_KEY = 'iaStyqKuqiBjgS7J6Td5'

	require 'rubygems'
	require 'nokogiri'
	require 'json'
	require 'net/http'
	require 'open-uri'

	def self.find(id)
		record = {}
		url = "http://api.digitalnz.org/v3/records/#{id}.json?api_key=#{DNZ_API_KEY}"
		response = Net::HTTP.get_response(URI.parse(url)).body.force_encoding("UTF-8")
		result = JSON.parse(response)
		title = result['record']['title'].gsub(/^(.*)\(([^(]+),(.*)\)/, '\1**\2**\3').split("**")
		record[:title] = title[0]
		record[:newspaper] = title[2]
		record[:date] = title[1]
		record[:fulltext] = result['record']['fulltext']
		record[:original] = result['record']['landing_url']
		article = Nokogiri::HTML(open(result['record']['landing_url']))
		record[:images] = article.css(".veridianimagecontainerdiv img")
		record
	end

	def self.search_results(query, options = {})
		url = "http://api.digitalnz.org/v3/records.json?api_key=#{DNZ_API_KEY}&and[primary_collection][]=Papers+Past&text=#{CGI::escape(query)}"
		response = Net::HTTP.get_response(URI.parse(url)).body.force_encoding("UTF-8")
		result = JSON.parse(response)
	end	

end