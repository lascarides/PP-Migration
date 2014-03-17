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

	def self.description
		"<strong>Papers Past</strong> contains more than three million pages of digitised New Zealand newspapers and periodicals. The collection covers the years 1839 to 1945 and includes 83 publications from all regions of New Zealand."
	end

end