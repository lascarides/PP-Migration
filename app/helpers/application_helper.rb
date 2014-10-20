module ApplicationHelper

	def veridian_id_to_route(veridian_id)
		url = "/#{@type}"
		if veridian_id =~ /^[A-Z]+\d{8}\.2/
			url += "/#{veridian_id}"
		else
			veridian_id_regex = /^([A-Z]+)(\d{4})(\d{2})(\d{2})(\.1\.)?(\d+)?/
			publication_id 	= veridian_id.gsub( veridian_id_regex, '\1')
			year 			= veridian_id.gsub( veridian_id_regex, '\2').to_i
			month 			= veridian_id.gsub( veridian_id_regex, '\3').to_i
			day 			= veridian_id.gsub( veridian_id_regex, '\4').to_i
			page_number 	= veridian_id.gsub( veridian_id_regex, '\6').to_i
			publication = Publication.info[publication_id]
			url += "/title/#{publication[:title].parameterize}"
			if day > 0 
				url += "/#{year}/#{month}/#{day}"
			end
			if page_number > 0
				url += "/#{page_number}"
			end
		end
		url
	end

	def veridian_id_to_page_number(veridian_id)
		veridian_id_regex = /^([A-Z]+)(\d{4})(\d{2})(\d{2})(\.1\.)(\d+)/
		page_number = veridian_id.gsub( veridian_id_regex, '\6').to_i
		if page_number == 0
			return nil
		end
		page_number
	end

end
