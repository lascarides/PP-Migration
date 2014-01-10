class DigitalNZ

	DNZ_API_KEY = 'iaStyqKuqiBjgS7J6Td5'

	require 'rubygems'
	require 'nokogiri'
	require 'json'
	require 'net/http'
	require 'open-uri'

	def self.find(id)
		url = "http://api.digitalnz.org/v3/records/#{id}.json?api_key=#{DNZ_API_KEY}"
		response = Net::HTTP.get_response(URI.parse(url)).body.force_encoding("UTF-8")
		result = JSON.parse(response)
		result['record']
	end

	def self.search_results(query, options = '')
		url = "http://api.digitalnz.org/v3/records.json?api_key=#{DNZ_API_KEY}&text=#{CGI::escape(query)}#{options}"
		response = Net::HTTP.get_response(URI.parse(url)).body.force_encoding("UTF-8")
		result = JSON.parse(response)
	end	

	def self.collections(options = '')
		url = "http://api.digitalnz.org/v3/records.json?api_key=#{DNZ_API_KEY}&per_page=0&facets_per_page=150&facets=collection#{options}"
		response = Net::HTTP.get_response(URI.parse(url)).body.force_encoding("UTF-8")
		result = JSON.parse(response)
		result.facets.collection
	end

end