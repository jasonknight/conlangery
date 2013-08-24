class Word < Sequel::Model(:words)
	set_primary_key :word_id
	def self.inspect_wordnet(word)
		puts "Class is: #{word.class}"
		puts "English: #{word.lemma}"
		word.morphs.each do |morph|
			puts morph.inspect
		end
	end
end