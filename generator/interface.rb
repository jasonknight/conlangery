require './target.rb'
require './lookup.rb'
require 'sequel'
require './dictionary_export.rb'
class Interface
  def initialize(tactics,lexor,word)
    @db = Sequel.sqlite('./data/target.sqlite')
    
    @tactics = tactics
    @lexor = lexor
    @suggestions = []
    @basic_words = File.open('basic_words.txt','r').read.split(',')
    @quit = false
    @begin_with = nil
    @end_with = nil

    if word
      search_word(word) 
    else
      show_hud
    end
  end
  def search_word(word)
    words = WordNet::Word.grep(:lemma , word)
    words.each do |w|
      @word = w
      generate_suggestions
      show_hud
    end
  end
  def format_word(word)
    transformations = {'ll' => 'y', 'ss' => 'x','slt' => 'sult'}
    transformations.each do |k,v|
        word.gsub!(k,v)
    end
    transformations.each do |k,v|
        word.gsub!(k,v)
    end
    transformations.each do |k,v|
        word.gsub!(k,v)
    end
    word.gsub!(/([aeiou]{3})/) { |m| ( m.split(//)[0] + m.split(//)[1] ) }
    word.gsub!(/([aeiou]{3})/) { |m| ( m.split(//)[0] + m.split(//)[1] ) }
    word.gsub(/([aeiou]{2})([bcdfghjklmnprstvxy]{1,2})([aeiou]{2})/) {|m| 
      parts = m.scan(/([aeiou]{2})([bcdfghjklmnprstvxy]{1,2})([aeiou]{2})/)
      if parts and parts[0] then
        parts = parts[0]
        new_part = parts[0].split(//).first + parts[1] + parts[2].split(//).last
      end
      new_part
    }

    return word
  end
  def already_defined?(word,pos,defn)
    @db[:words].where(['english = ? and definition = ? and part_of_speech = ?',word.to_s,defn.to_s,pos.to_s]).any?
  end
  def target_word_exists?(word)
    @db[:words].where(['target_language = ?',word.to_s]).any?
  end
  def generate_suggestions
    @suggestions = []
    i = 0
    @word.definitions.each do |pos,defns|
      base_word = nil
      defns.each do |defn|
        next if already_defined?(@word.lemma,pos,defn[:defn])
        target_word = ''
        begin
          target_word = @lexor.generate_word( pos.to_sym )
          next if base_word and base_word[:middles].include? target_word[:middle]
          if @begin_with
            target_word[:start] = @begin_with
            target_word[:middle] = ''
          end
          if @end_with then
            target_word[:end] = @end_with
          end
          if base_word.nil? then
            base_word = target_word
            base_word[:middles] = [target_word[:middle]]
          else 
            base_word[:middles] << target_word[:middle]
          end
          target_word = @lexor.merge_words(pos.to_sym,base_word,target_word)
          formatted_word = format_word(format_word(target_word.values.join))
        end while target_word_exists?(formatted_word)
        
        


        @suggestions[i] = { 
          :english => @word.lemma, 
          :target_language => formatted_word, 
          :part_of_speech => pos, 
          :definition => defn[:defn],
          :wordnet_wordid => defn[:wordnet_wordid],
          :wordnet_synsetid => defn[:syn].synsetid
        }
        i += 1
      end
    end
    if @suggestions.length < 1 then
      puts "All meanings for this word '#{@word.lemma}' have been saved"
      return
    end
    display_suggestions(@suggestions)
  end
  def show_hud
    return if @quit == true
    print "Words(#{Target.count}/#{Target.total_words}) Help(?): "
    choose_option()
  end
  def set_var(inp)
    parts = inp.scan(/^set ([\w]+) (.*)/)
    parts[0][1] = nil if parts[0][1] == 'nil'
    instance_variable_set("@#{parts[0][0]}".to_sym,parts[0][1])
    puts "New value of @#{parts[0][0]} is: " + instance_variable_get("@#{parts[0][0]}".to_sym).inspect
  end
  def choose_option
    return if @quit == true
    $stdout.flush
    inp = $stdin.gets().chomp();
    case inp
      when '?' then show_help
      when 'r' then generate_suggestions
      when /^s [\d ]+ as \d+/ then save_suggestions_as(inp)
      when /^s / then save_suggestions(inp)
      when /^l / then lookup(inp)
      when 'q' then @quit = true
      when /^cognate / then save_cognate(inp)
      when /^try / then try_finding(inp)
      when /^synsets/ then display_synsets
      when /^export/ then export
      when /^all/ then save_all_suggestions
      when /^next/ then go_to_next_basic_word
      when /^set/ then set_var(inp)
      when /^stats/ then show_stats
      when /^verb table / then export_verb_table(inp)
    end
    return if @quit == true
    show_hud
  end
  def show_stats
    uniq_eng = Target.count_english
    verbs = Target.count_verbs
    nouns = Target.count_nouns
    adverbs = Target.count_adverbs
    adjectives = Target.count_adjectives
    puts %Q[
      Total Words: #{Target.total_words}
      Distinct in target language #{Target.count}
      Distinct in english #{Target.count_english}
      Verbs #{verbs}
      Adverbs #{adverbs}
      Nouns #{nouns}
      Adjectives #{adjectives}
    ]
  end
  def export
    DictionaryExport.new(@db).export
  end
  def export_verb_table(inp)
    word = inp.scan(/^verb table (\w+)/)
    DictionaryExport.new(@db).export_verb_table(word[0][0])
  end
  def get_defined_words( word, definition, pos )
    words = @db[:words].where(
          ['english = ? and definition = ? and part_of_speech = ?',
            word, 
            definition,
            pos]
        )
    if words then
      return words
    end
    return []
  end
  def display_synsets
    puts "Displaying Synsets"
    @word.synsets.each do |syn|
      syn_words = syn.words.collect {|w| w.lemma }.join(', ')
      next if syn_words == @word.lemma
      #puts "\t" + syn_words + ": \t\t" + syn.definition
      target_word = nil
      syn.words.each do |sword|
        target_words = get_defined_words(
            sword.lemma, 
            syn.definition,
            WordNet::WORDTYPES[syn.pos].to_s
        )
        if target_words.any? and not target_word then
          target_word = target_words.first
        end
      end
      if target_word then
        puts "Target word is #{target_word[:english]}"
        syn.words.each do |sword|
          puts "sword is #{sword.lemma}"
          already_defined_words = get_defined_words(
            sword.lemma, 
            syn.definition,
            WordNet::WORDTYPES[syn.pos].to_s
          )
          if already_defined_words.any? then
            puts "sword already defined"
            last_defined = already_defined_words.first
          else
            data = {}
            data[:english] = sword.lemma
            data[:part_of_speech] = WordNet::WORDTYPES[syn.pos].to_s
            data[:definition] = syn.definition
            data[:target_language] = target_word[:target_language]
            @db[:words].insert(data)
            last_defined = get_defined_words(
              sword.lemma, 
              syn.definition,
              WordNet::WORDTYPES[syn.pos].to_s
            ).first
          end
          the_word = Target::Word.find(:word_id => target_word[:word_id])
          the_synonym = Target::Word.find(:word_id => last_defined[:word_id])
          found = the_word.has_synonym(the_synonym.word_id)

          if not found then
            puts "No synonym is set! #{the_word.word_id} and #{the_synonym.word_id}"
            data = {}
            data[:word1_id] = the_word.word_id
            data[:word2_id] = the_synonym.word_id
            @db[:synonyms].insert(data)
          else
            puts "synonym is already setup!"
          end
        end # end syn.words.each
      end
      
    end
  end
  def go_to_next_basic_word
    search_word( @basic_words.shift )
  end
  def try_finding(inp)
    word = inp.scan(/^try (.+)/)
    if word then
      search_word(word[0][0])
    end
  end
  def save_cognate(inp)
    nums = inp.scan(/(\d+)/)
    if nums then 
      nums.each do |num|
        Target::Word.from_suggestion_as_cognate( @suggestions[ num[0].to_i ] )
      end
    end
  end
  def lookup(inp)
    word = inp.scan(/^l (.+)/)
    if word[0] then
      word = word[0][0]
    else 
      word = 'klingon'
    end
    if word then
      Lookup.new(@db).find(word)
    end
  end
  def save_suggestions(inp)
    nums = inp.scan(/(\d+)/)
    if nums then 
      nums.each do |num|
        Target::Word.from_suggestion( @suggestions[ num[0].to_i ] )
      end
    end
  end
  def save_all_suggestions
    (0..@suggestions.length).each { |i| Target::Word.from_suggestion( @suggestions[ i ] ) if @suggestions[i] }
  end
  def save_suggestions_as(inp)
    inp = inp.split('as')
    as_s = inp[1].scan(/(\d+)/)[0][0]
    nums = inp[0].scan(/(\d+)/)
    if nums then 
      nums.each do |num|
        Target::Word.from_suggestion_as( @suggestions[ num[0].to_i ], @suggestions[ as_s.to_i ] )
      end
    end
  end
  def display_records(records)

  end
  def display_suggestions( suggestions )
    i = 0
    suggestions.each do |s|
      puts "% 8s % 15s % 15s #% 3d %s" % [s[:part_of_speech].to_s, s[:english], s[:target_language],i, s[:definition]]
      i += 1
    end
  end
  def show_help
    puts "Save :s 1 2 3 n   which will save the suggestions as is."
    puts "Save :s 1 2 3 4 as 1  which will save the listed suggestions but as the target word of 1, i.e create synonyms"
    puts "Redisplay  :r "
    puts "Don't acutally use a :, the : just means prompt"
  end
end