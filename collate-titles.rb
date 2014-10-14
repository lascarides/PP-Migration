n = {}
NewspaperTitle.info.each{|sym,vals| n[vals[:region]] ||= []; n[vals[:region]] << "{\"id\": \"#{sym}\", \"name\": \"#{vals[:title]}\", \"start-year\": \"#{vals[:start_year]}\", \"end-year\": \"#{vals[:end_year]}\"" }
n.each{ |r,v| puts '"' + r + '": [' + v.join(',') + ' ]'}