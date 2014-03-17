class Periodical < NLNZObject

	def self.dnz_search_scope
		'&or[primary_collection][]=Te+Ao+Hou&or[primary_collection][]=Transactions+and+Proceedings+of+the+Royal+Society+of+New+Zealand+1868-1961'
	end

	def self.description
		"<strong>Papers Past</strong> contains dozens of fully-digitised magazines and journals from the 19th century to the present day on a wide variety of topics."
	end

end