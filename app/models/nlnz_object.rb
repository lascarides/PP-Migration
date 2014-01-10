class NLNZObject

	def self.find(dnz_id)
		DigitalNZ.find(dnz_id)		
	end

	def self.search_results(search_term)
		DigitalNZ.search_results(search_term, self.dnz_search_scope)		
	end

	def self.collections(search_term)
		DigitalNZ.collections(self.dnz_search_scope)		
	end

	def self.dnz_search_scope
		''
	end

end