class NLNZObject

	def self.find(dnz_id)
		DigitalNZ.find(dnz_id)		
	end

	def self.search_results(search_term)
		DigitalNZ.search_results(search_term)		
	end
end