# coding: UTF-8
require 'sequel'
require './target.rb'
require 'awesome_print'
class DictionaryExport
	def initialize(db)
		@db = db
		@reps = {:ng => 'ŋ', :ae => 'ae',:kh => 'kh',:oe => 'oe',:ea => 'ea',:ts => 'ts',:aa => 'aa',:ee => 'ee', :oo => 'oo'}
	end
	def clean(new_word)
	    @reps.each do |k,v|
	        new_word = new_word.gsub(/#{k.to_s}/,v.to_s)
	    end
	    return new_word
	end
	def export_verb_table(target_word)
		words = @db[:words].where(:target_language => target_word, :part_of_speech => 'verb')
		defns = words.collect {|w| w[:definition]}
		puts %Q[
			\\begin{table}
				\\caption{ #{ target_word } - #{ defns.first }}
				\\centering
				% Tense & 1st Person & 2nd Singular & 2nd Plural & He & She & It
				\\begin{tabular}{ l l l l l l l }
					l
				\\end{tabular}
				\\label{table:verb_#{target_word}}
			\\end{table}
		]
	end
	def export
		@words_for_export = {}
		@db[:words].order_by(:english).each do |word|
			eword = word[:english].strip
			next if not "abcdefghijklmnopqrstuvwxyz".split(//).include? eword[0]
			next if eword.include? ' '
			@words_for_export[ eword ] ||= {}
			@words_for_export[ eword ][ word[:part_of_speech] ] ||= {}
			@words_for_export[ eword ][ word[:part_of_speech] ][ word[:definition] ] ||= []
			@words_for_export[ eword ][ word[:part_of_speech] ][ word[:definition] ] << { :word => word[:target_language].strip, :data => word}
		end
		write_words( @words_for_export,'dictionary_export.txt' )
		@words_for_export = {}
		@db[:words].order_by(:target_language).each do |word|
			eword = word[:target_language].strip
			#next if not "abcdefghijklmnopqrstuvwxyz".split(//).include? eword[0]
			#next if eword.include? ' '
			@words_for_export[ eword ] ||= {}
			@words_for_export[ eword ][ word[:part_of_speech] ] ||= {}
			@words_for_export[ eword ][ word[:part_of_speech] ][ word[:definition] ] ||= []
			@words_for_export[ eword ][ word[:part_of_speech] ][ word[:definition] ] << { :word => word[:english].strip, :data => word}
		end
		write_words( @words_for_export,'dictionary_export_reverse.txt',true )
	end
	def write_words(words, fname, apply_reps=false)
		init_letter = ''
		File.open(fname,'w+') do | f |
			words.sort.each do | word, entry |
				puts "Word is: #{word}"
				next if word.nil? or word.empty?
				if apply_reps and @reps.keys.include? word[0,2].to_sym then
					if init_letter != word[0,2] then
						init_letter = word[0,2]
						f.puts "\\subsection*{#{@reps[init_letter.to_sym].upcase}}\n\n"
					end
				elsif apply_reps and not @reps.keys.include? word[0,1].to_sym then
					if init_letter != word[0] then
						init_letter = word[0]
						f.puts "\\subsection*{#{init_letter.upcase}}\n\n"
					end
				else
					if init_letter != word[0] then
						init_letter = word[0]
						f.puts "\\subsection*{#{init_letter.upcase}}\n\n"
					end
				end
				
				entry.each do |pos, defn |
					f.puts get_entry_format(word,pos,defn,apply_reps) + "\n\n"
					#get_entry_format(word,pos,defn)
				end
			end
		end
	end
	def clean_entry(entry)
		entry.gsub!('_','\_')

		return entry
	end
	def get_entry_format(word,pos,defn, apply_reps=false)
		new_word = "#{word}"
		if apply_reps then
			@reps.each do |k,v|
				new_word = new_word.gsub(/#{k.to_s}/,v.to_s)
			end
		end
		entry = "\\entry{#{new_word }} \\pos{#{pos}} "
		defs = {}
		entry_defs = []

		defn.each do |definition, new_word_list |
			new_words = new_word_list.collect { |w| w[:word] }
			defs[ new_words.join(', ') ] ||= []
			defs[ new_words.join(', ') ] << definition
		end
		
		defs.each do |tnew_word , sdefs|
			if not apply_reps then
				@reps.each do |k,v|
					tnew_word = tnew_word.gsub(/#{k.to_s}/,v.to_s)
				end
			end

			uniq_defs = sdefs.uniq!
			uniq_defs = sdefs if uniq_defs.nil?

			if not tnew_word.include? ','
				entry_defs << uniq_defs.join(" \\textit{or} ") + ": \\vocab{#{tnew_word }}."
				puts 'Had comma'
		 	else
		 		puts "no comma"
		 		tdef = uniq_defs.join(" \\textit{or} ") + ": "
		 		tdef_list = []
		 		tnew_word .split(',').each do |split_new_word |
		 			tdef_list <<  " \\vocab{#{tnew_word }} "
		 		end
		 		uniq_tdef_list = tdef_list.uniq
		 		uniq_tdef_list = tdef_list if not uniq_tdef_list
		 		tdef += uniq_tdef_list.join(', ')
		 		entry_defs << tdef + "."
		 	end
		end
		entry += entry_defs.join(" ")
		return clean_entry(entry)
	end
end