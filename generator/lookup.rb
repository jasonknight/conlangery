require 'sequel'
require './target.rb'
class Lookup
  include Target
	def initialize(db)
		@db = db
		@results = []
		@quit = false
	end
	def delete_word(word_id)
	    dataset = @db[:words]
	    word = Target::Word.find(:word_id => word_id)
	    word.remove_syn_connections
	    begin
	    	word.delete
	    rescue
	    	puts $!.inspect
	    end	
	end
	def remove_all_word(word_id)
	    dataset = @db[:words]
	    word = Target::Word.find(:word_id => word_id)
	    word.remove_completely
	    begin
	    	word.delete
	    rescue
	    	puts $!.inspect
	    end	
	end
	def create_word
		insert_new_word_from_input
		display_interface
	end
	def choose
		return if @quit
		inp = $stdin.gets.chomp
		puts "Input is: #{inp}"
		if inp.match /^l / then
			res = inp.scan(/^l (.*)/)
            find(res[0][0]) if res
        elsif inp.match(/^english (.*)/) then
        	puts " english found"
			res = inp.scan(/^english (.*)/)
			puts res.inspect
            find2(res[0][0],:english) if res
        elsif inp.match(/^target (.*)/) then
			res = inp.scan(/^target (.*)/)
            find2(res[0][0],:target_language) if res
        elsif inp.match /^x / then
        	num = inp.scan(/(\d+)/)
            if num then
                num.each do |n|
                    delete_word(n[0].to_i)
                end
            end
        elsif inp.match /^s / then
        	num = inp.scan(/(\d+)/)
            if num then
                num.each do |n|
                   display_result(n[0].to_i) 
                end
            end
        elsif inp.match /^n / then
        	insert_new_word_from_input
        elsif inp.match /^e / then
        	num = inp.scan(/(\d+)/)
            if num then
                num.each do |n|
                   edit_record(n[0].to_i) 
                end
            end
        elsif inp == 'q' then
        	@quit = true
        	return
        elsif inp.match /^c / then
        	puts "Copying"
        	num = inp.scan(/^c (\d+)/)
        	puts num.inspect
            if num then
                num.each do |n|
                   copy_record(n[0].to_i,inp) 
                end
            end
        elsif inp.match /^remove all / then
        	num = inp.scan(/^remove all (\d+)/)
            if num then
                num.each do |n|
                   remove_all_word(n[0].to_i) 
                end
            end
        elsif inp.match(/^defn /) then
        	res = inp.scan(/^defn (.*)/)
            find_in_definition(res[0][0]) if res
        elsif inp.match(/^rep_target/)
        	replace_target_word(inp)
        end
        display_interface
	end
	def replace_target_word(inp)
		m = inp.scan(/^rep_target ([\w']+) ([\w']+)/)
		puts "finding #{m[0][0]} and replacing with #{m[0][1]}"
		word_ids = @db[:words].where( :target_language => m[0][0]).collect { |w| w[:word_id] }
		word_ids.each do |id|
			rec = Target::Word.find( :word_id => id )
			rec.target_language = m[0][1]
			rec.save
		end
	end
	def display_interface
		return if @quit
		print "Lookup(l) Show(s) n1,nx ..., Delete(x) n1,nx ..., New(n), Edit(e), Copy(c) n, Quit(q)\nChoose: "
		choose
	end
	def word_wrap(text,limit=80)
		new_text = ''
    length_since = 0
		text.split(" ").each do |word|
			if (length_since) > limit then
				new_text += "\n"
        length_since = 0
			end
			new_text += " " + word;
      length_since += word.length + 1
		end
		return new_text
	end
	def hr()
		return "------------------------------------------------------------------------------------------"
	end
	def find(word)
		@results = []
		dataset = @db[:words]
		ids_seen = []
	    print "Searching #{dataset.count} records "
	    results = dataset.grep(:english, "%#{word}%")
	    results2 = dataset.grep(:target_language, "%#{word}%")
	    results.each {|row| 
	    	if not ids_seen.include? row[:word_id]
	    		@results << row
	    		ids_seen << row[:word_id]
	    	end
	    }
	    results2.each {|row| 
	    	if not ids_seen.include? row[:word_id]
	    		@results << row
	    		ids_seen << row[:word_id]
	    	end
	    }
	    print "and #{@results.length} where found.\n"
	    display_small_entries(@results)
	end
	def find2(word,type)
		@results = []
		dataset = @db[:words]
		ids_seen = []
	    print "Searching #{dataset.count} records "
	    if type == :english then
	    	results = dataset.grep(:english, "#{word}%")
	    else
	    	results = dataset.grep(:target_language, "#{word}%")
	    end
	    results.each {|row| 
	    	if not ids_seen.include? row[:word_id]
	    		@results << row
	    		ids_seen << row[:word_id]
	    	end
	    }
	    print "and #{@results.length} where found.\n"
	    display_small_entries(@results)
	end
	def find_in_definition(words)
		puts "Searching for: #{words}"
		@results = []
		dataset = @db[:words]
		ids_seen = []
	    print "Searching #{dataset.count} records "
	    if (words.include? '+') then
	    	word = words.split('+').join('%')
	    else
	    	word = words
	    end
	    results = dataset.grep(:definition, "%#{word}%")
	    results.each {|row| 
	    	if not ids_seen.include? row[:word_id]
	    		@results << row
	    		ids_seen << row[:word_id]
	    	end
	    }
	    print "and #{@results.length} where found.\n"
	    display_small_entries(@results)
	end
	def display_result(id)
		row = nil
		@results.each do |res|
			if res[:word_id].to_i == id.to_i then
				row = res
				break
			end
		end
		if row.nil? then
			puts "That id(#{id}) is not in the result set"
			return
		end
		num = sprintf '#%d',row[:word_id].to_i
        eng = row[:english]
        pos = row[:part_of_speech]
        kli = row[:target_language]
        defn = word_wrap( row[:definition] )
        puts %Q[#{num} #{eng} (#{pos}) : #{kli}
#{hr()}
#{defn}
#{hr()}]
	end
	def pos_to_abbrev(pos)
		case pos
			when 'adjective' then return 'adjt'
			when 'adverb' then return 'advb'
			when 'noun' then return 'noun'
			when 'verb' then return 'verb'
			else return pos[0,4]
		end
	end
	def get_small_entry(row)
		num = sprintf '#% 5d',row[:word_id].to_i
		eng = sprintf '% 15s', row[:english]
	  	pos = pos_to_abbrev row[:part_of_speech]
	  	kli = sprintf '% 15s', row[:target_language]
	    defn =  sprintf '% 70s',row[:definition][0,60]
		entry = "#{num} #{eng} (#{pos}) #{kli} #{defn}"
		return entry
	end
	def display_small_entries(results,limit=80)
		text = ''
		puts hr
		results.each do |row|
			entry = get_small_entry(row)
			if (text.length + entry.length + 1) > limit then
				text += "\n"
			end
			text += entry
		end
		puts text
		puts hr
		display_interface
	end
	def copy_record(word_id,inp)
		words = inp.scan(/as (.+)/)
		if words[0] then
			words = words[0][0].split(',')
		end
		dataset = @db[:words]
		begin
			sword = Word.find( :word_id => word_id)
		rescue
			puts "Could not load record"
			puts $!
			return
		end
		new_word = {}
		keys = [:english, :part_of_speech, :definition, :target_language]
		keys.each do |k|
			new_word[k] = sword[k]
		end
		if words then
			words.each do |word|
				new_word[:english] = word
				dataset.insert(new_word)
			end
		else
			print "english: " 
			new_word[:english] = $stdin.gets.chomp
			dataset.insert(new_word)
		end
	end
	def edit_record(word_id)
		dataset = @db[:words]
		begin
			word = Word.find( :word_id => word_id)
		rescue
			puts "Could not load record"
			puts $!
			return
		end
		keys = [:english, :part_of_speech, :definition, :target_language]
		new_values = {}
		dirty = false
		keys.each do |k|
			print "#{k}(#{word[k]}):"
			new_value = $stdin.gets.chomp
			if ! new_value.empty? then
				new_values[k] = new_value
				dirty = true
			end
		end
		if dirty
			word.update(new_values)
		else
			puts "nothing to update"
		end
	end
	def insert_new_word_from_input
	    puts "Inserting a new word"
	    dataset = @db[:words]
	    data = {}
	    keys = [:english, :part_of_speech, :definition, :target_language]
	    keys.each do |k|
	        print "#{k}: "
	        data[k] = $stdin.gets.chomp
	    end
	    keys.each do |k|
	        puts "#{k} = #{data[k]}"
	    end
	    print "Insert? (y)es, (n)o, (r)etry: "
	    inp = $stdin.gets.chomp
	    if inp == 'y' then
	        dataset.insert(data)
	        puts dataset.order(:word_id).last.inspect
	    elsif inp == 'n' then
	        return
	    elsif inp == 'r' then
	        insert_new_word_from_input
	    end
	    return
	end
end