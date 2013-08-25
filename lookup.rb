require 'sequel'
require './word.rb'
class Lookup
	def initialize(db)
		@db = db
		Word.db = @db
		@results = []
		@quit = false
	end
	def delete_word(word_id)
	    dataset = @db[:words]
	    dataset.where(:word_id => word_id).delete if dataset.where(:word_id => word_id).any?
	end
	def create_word
		insert_new_word_from_input
		display_interface
	end
	def choose
		return if @quit
		inp = gets.chomp
		if inp.match(/^l (.*)/) then
			res = inp.scan(/^l (.*)/)
            find(res[0][0]) if res
        elsif inp.match(/^english (.*)/) then
        	puts " english found"
			res = inp.scan(/^english (.*)/)
			puts res.inspect
            find2(res[0][0],:english) if res
        elsif inp.index('target ') == 0 then
			res = inp.scan(/target (.*)/)
            find2(res[0][0],:target_language) if res
        elsif inp.include? 'x ' then
        	num = inp.scan(/(\d+)/)
            if num then
                num.each do |n|
                    delete_word(n[0].to_i)
                end
            end
        elsif inp.include? 's ' then
        	num = inp.scan(/(\d+)/)
            if num then
                num.each do |n|
                   display_result(n[0].to_i) 
                end
            end
        elsif inp.include? 'n' then
        	insert_new_word_from_input
        elsif inp.include? 'e ' then
        	num = inp.scan(/(\d+)/)
            if num then
                num.each do |n|
                   edit_record(n[0].to_i) 
                end
            end
        elsif inp == 'q' then
        	@quit = true
        	return
        elsif inp.index('c ') == 0 then
        	num = inp.scan(/(\d+)/)
            if num then
                num.each do |n|
                   copy_record(n[0].to_i) 
                end
            end
        end
        display_interface
	end
	def display_interface
		return if @quit
		print "Lookup(l) Show(s) n1,nx ..., Delete(x) n1,nx ..., New(n), Edit(e), Copy(c) n, Quit(q)\nChoose: "
		choose
	end
	def word_wrap(text,limit=80)
		new_text = ''
		text.split(" ").each do |word|
			if (new_text.length + word.length + 1) > limit then
				new_text += "\n"
			end
			new_text += " " + word;
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
		eng = sprintf '% 30s', row[:english]
    	pos = pos_to_abbrev row[:part_of_speech]
    	kli = sprintf '% 30s', row[:target_language]
		entry = "#{num} #{eng} (#{pos}) #{kli}\n#{row[:definition][0,60]}"
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
	def copy_record(word_id)
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
		print "english: " 
		new_word[:english] = gets.chomp
		dataset.insert(new_word)
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
			new_value = gets.chomp
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
	        data[k] = gets.chomp
	    end
	    keys.each do |k|
	        puts "#{k} = #{data[k]}"
	    end
	    print "Insert? (y)es, (n)o, (r)etry: "
	    inp = gets.chomp
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