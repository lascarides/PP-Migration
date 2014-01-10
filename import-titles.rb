# This is a quick script to pull basic information about Papers Past titles
# into a local data structure

require 'rubygems'
require 'nokogiri'
require 'json'
require 'net/http'
require 'open-uri'
require 'pp'

source = "http://paperspast.natlib.govt.nz/cgi-bin/paperspast?a=d&cl=CL1"

content = {}

titles = Nokogiri::HTML(open(source))
titles.css(".tri-list li a").each do |item|
	x = item.to_s
	pattern = /^.*cl=CL1\.([A-Z]+).*>(.*)\((.*), (\d\d\d\d)-?(\d\d\d\d)?\)<.*$/
	code 		= x.gsub(pattern, '\1').strip
	title 		= x.gsub(pattern, '\2').strip
	region 		= x.gsub(pattern, '\3').strip
	start_year 	= x.gsub(pattern, '\4').strip
	end_year 	= x.gsub(pattern, '\5').strip
	content[code] = {
		:title => title,
		:region => region,
		:start_year => start_year,
		:end_year => end_year.nil? ? start_year : end_year,
		:logo => "http://paperspast.natlib.govt.nz/custom/paperspast/images/mastheads/#{code}.gif"
	}
end

content.each do |code, title|
	puts "Fetching #{code}..."

	# INFO PAGE
	page = "http://paperspast.natlib.govt.nz/cgi-bin/paperspast?a=d&cl=CL1.#{code}&e=-------10--1----0--"
	page = Nokogiri::HTML(open(page))
	content[code][:short_desc] = page.css('#nm-blurb p').to_s.gsub(/<\/?p>/, '')
	page.css('.nm-info p').each do |para|
		para = para.to_s
		if para =~ /Available online/
			pattern = /^.*Available online: (.*) - (.*) \((.*) issues\).*$/
			content[code][:start_date] = para.gsub(pattern, '\1').strip
			content[code][:end_date] = para.gsub(pattern, '\2').strip
			content[code][:issue_count] = para.gsub(pattern, '\3').to_i
		end
	end


	# ESSAY
	page = "http://paperspast.natlib.govt.nz/cgi-bin/paperspast?a=d&cl=CL1.#{code}&essay=1&e=-------10--1----0--"
	page = Nokogiri::HTML(open(page))
	content[code][:essay] = page.css('.inner-contentwrap').to_s.strip.gsub("\n", ' ')
end

puts "SNIP ---------------------------------------------------------"

pp content


