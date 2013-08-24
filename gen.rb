#!/usr/bin/env ruby
require 'wordnet/lexicon'
require 'sequel'
require './lookup.rb'
$generated_words = []
class DummySynset
    attr_accessor :words, :part_of_speech, :definition
    def initialize(word,pos,defn)
        @words = word
        @part_of_speech = pos
        @definition = defn
    end
end

@db = Sequel.sqlite('kli.sqlite3')
begin
    @db.run(%Q[
        CREATE TABLE words (
            word_id INTEGER PRIMARY KEY AUTOINCREMENT,
            english VARCHAR(255) NOT NULL, 
            target VARCHAR(255) NOT NULL, 
            definition TEXT,
            part_of_speech VARCHAR(255) NOT NULL
        );
    ])
rescue
    puts $!.inspect
end
begin
    @db.run(%Q[
        CREATE TABLE synonyms (
            word1_id INTEGER,
            word2_id INTEGER
        );
    ])
rescue
    puts $!.inspect
end
begin
    @db.run(%Q[
        CREATE TABLE examples (
            word_id INTEGER,
            example TEXT
        );
    ])
rescue
    puts $!.inspect
end
@lexicon = WordNet::Lexicon.new
@tenses = {
    'immediate future' =>{ 
        'template' => "$word",
        'definition' => "right now",
    },
    'near future' => {
        'template' => 'vo      ... $word',
        'definition' => 'soon ...',
        'english' => 'soon',
        'kli' => 'vo'
    },
    'relative hodiernal future' => {
        'template' => 'kij     ... $word',
        'definition' => 'later in that day ...',
        'english' => 'later',
        'kli' => 'kij'
    },
    'hodiernal future' => {
        'template' => 'suj     ... $word',
        'definition' => 'later today ...',
        'english' => 'later',
        'kli' => 'suj'
    },
    'remote future' => {
        'template' => 'raj     ... $word',
        'definition' => 'simple future, within one week(5 days) ...',
        'english' => 'sometime',
        'kli' => 'raj'
    },
    'far future' => {
        'template' => 'rosij   ... $word',
        'definition' => 'someday ...',
        'english' => 'someday',
        'kli' => 'rosij'
    },
    'simple past' => {
        'template' => "yaisg   ... $word",
        'definition' => 'did ...',
        'english' => '',
        'kli' => 'yaisg'
    },
    'remote past' => {
        'template' => "sai     ... $word",
        'definition' => 'simple past, within one week(5 days) ...',
        'english' => '',
        'kli' => 'sai'
    },
    'relative hodiernal past' => {
        'template' => 'sata    ... $word',
        'definition' => 'earlier that day ...',
        'english' => 'earlier',
        'kli' => 'sata'
    },
    'hodiernal past' => {
        'template' => 'soto    ... $word',
        'definition' => 'earlier today ...',
        'english' => 'earlier',
        'kli' => 'sata'
    },
    'far past' => {
        'template' => 'umkajaj ... $word',
        'definition' => 'a long time ago ...',
        'kli' => 'umkajaj'
    },
}
@verb_moods = {
    'ability' => {
        'template' => '$wordlah',
        'explanation' => "can, is able to ...",
        'english' => ['can','auxiliary verb'],
        'kli' => ['-lah','verb suffix']
    },
    'probability1' => {
        'template' => '$wordjaj',
        'explanation' => "may ...",
        'english' => ['may','auxiliary verb'],
        'kli' => ['-jaj','verb suffix']
    },
    'probability2' => {
        'template' => "$wordjaj'a",
        'explanation' => "might ...",
        'english' => ['might','auxiliary verb'],
        'kli' => ["-jaj'a'",'verb suffix']
    },
    'obligation1' => {
        'template' => '$wordlas',
        'explanation' => "must ...",
        'english' => ['must','auxiliary verb'],
        'kli' => ["-las'",'verb suffix']
    },
    'obligation2' => {
        'template' => "$word'el",
        'explanation' => "should ...",
        'english' => ['should','auxiliary verb'],
        'kli' => ["-'el'",'verb suffix']
    },
    'imperative' => {
        'template' => "$wordzan",
        'explanation' => "Do this now ...",
        'english' => ['now','auxiliary verb'],
        'kli' => ["-zan",'verb suffix']
    },
    'interrogative' => {
        'template' => "$wordna",
        'explanation' => "will ...",
        'english' => ['will','auxiliary verb'],
        'kli' => ["-na",'verb suffix']
    },

}
@english_prefixes = {
    'a' => {
        'kli' => 'yu',
        'sense' => 'predictive progressive, afloat, awash'
    },
    'ambi' => {
        'kli' => 'nu',
        'sense' => 'both'
    },
    'amphi' => {
        'kli' => 'otor',
        'sense' => 'around, surround'
    },
    'ana' => {
        'kli' => "ede",
        'sense' => "up, back, anew"
    },
    'ano' => {
        'kli' => "ede",
        'sense' => "up, back, anew"
    },
    'ante' => {
        'kli' => 'krim',
        'sense' => 'before'
    },
    'ant' => {
        'kli' => 'krim',
        'sense' => 'before'
    },
    'anti' => {
        'kli' => 'sus',
        'sense' => 'against,opposite'
    },
    'apo' => {
        'kli' => 'suru',
        'sense' => 'away from'
    },
    'arch' => {
        'kli' => "'os",
        'sense' => 'supreme, highest, best, biggest'
    },
    'be' => {
        'kli' => 'vav',
        'sense' => 'equipped with, covered with'
    },
    'bi' => {
        'kli' => 'nu',
        'sense' => 'both of two'
    },
    'bibl' => {
        'kli' => 'vral',
        'sense' => 'book, having to do with books'
    },
    'bibli' => {
        'kli' => 'vral',
        'sense' => 'book, having to do with books'
    },
    'biblio' => {
        'kli' => 'vral',
        'sense' => 'book, having to do with books'
    },
    'bio' => {
        'kli' => "oke",
        'sense' => 'having to do with biological things'
    },
    'cad' => {
        'kli' => 'jon',
        'sense' => 'to seize'
    },
    'cap' => {
        'kli' => 'jon',
        'sense' => 'to seize'
    },
    'caus' => {
        'kli' => 'mek',
        'sense' => 'burn, heat'
    },
    'circum' => {
        'kli' => 'otor',
        'sense' => 'around, about, surrounding'
    },
    'co' => {
        'kli' => 'utsul',
        'sense' => 'joint, accompanying, with'
    },
    'cog' => {
        'kli' => 'utsul',
        'sense' => 'joint, accompanying, with'
    },
    'col' => {
        'kli' => 'utsul',
        'sense' => 'joint, accompanying, with'
    },
    'com' => {
        'kli' => 'utsul',
        'sense' => 'joint, accompanying, with'
    },
    'con' => {
        'kli' => 'utsul',
        'sense' => 'joint, accompanying, with'
    },
    'contra' => {
        'kli' => 'sus',
        'sense' => 'against,opposite'
    },
    'counter' => {
        'kli' => 'sus',
        'sense' => 'against,opposite'
    },
    'corp' => {
        'kli' => 'torgh',
        'sense' => 'body'
    },
    'de' => {
        'kli' => "lus",
        'sense' => 'not, reverse action, opposite'
    },
    'dec' => {
        'kli' => "mah",
        'sense' => 'ten, 10'
    },
    'deca' => {
        'kli' => "mah",
        'sense' => 'ten, 10'
    },
    'dis' => {
        'kli' => "lus",
        'sense' => 'not, opposite of'
    },
    'dif' => {
        'kli' => "lus",
        'sense' => 'not, opposite of'
    },
    'dict' => {
        'kli' => "jatl",
        'sense' => 'speaking, saying'
    },
    'dei' => {
        'kli' => "kun",
        'sense' => 'god'
    },
    'divi' => {
        'kli' => "kun",
        'sense' => 'god'
    },
    'div' => {
        'kli' => "lis",
        'sense' => 'separate'
    },
    'demo' => {
        'kli' => "klin",
        'sense' => 'people'
    },
    'doc' => {
        'kli' => "goj",
        'sense' => 'teach'
    },
    'dual' => {
        'kli' => 'nu',
        'sense' => 'both of two'
    },
    'dys' => {
        'kli' => "luja",
        'sense' => 'fail, fault'
    },
    'ec' => {
        'kli' => "dek",
        'sense' => 'out of, from'
    },
    'eco' => {
        'kli' => "hyul",
        'sense' => 'household, environment, local area'
    },
    'ecto' => {
        'kli' => "dek",
        'sense' => 'out of, from'
    },
    'en' => {
        'kli' => 'bal',
        'sense' => 'get into, enmesh'
    },
    'endo' => {
        'kli' => 'aes',
        'sense' => 'within, inside'
    },
    'em' => {
        'kli' => 'bal',
        'sense' => 'get into, put into, empower'
    },
    'ex' => {
        'kli' => 'mu',
        'sense' =>'former'
    },
    'lang' => {
        'kli' => 'aase',
        'sense' => 'having to do with language, a tool'
    },
    'fore' => {
        'kli' => 'krim',
        'sense' => 'before, in front'
    },
    'hind' => {
        'kli' => 'adah',
        'sense' => 'after'
    },
    'mal' => {
        'kli' => 'usul',
        'sense' => 'bad, badly'
    },
    'mid' => {
        'kli' => 'hraj',
        'sense' => 'middle, between'
    },
    'mini' => {
        'kli' =>"om",
        'sense' => 'small, miniature'
    },
    'mis' => {
        'kli' => "'oe",
        'sense' => 'wrong, astray'
    },
    'out' => {
        'kli' => "'os",
        'sense' => 'better, faster'
    },
    'over' => {
        'kli' => 'hotsil',
        'sense' => 'excessive, above'
    },
    'peri' => {
        'kli' => 'ulari',
        'sense' => 'around, near, nearby'
    },
    'post' => {
        'kli' => 'ada',
        'sense' => 'after,behind'
    },
    'pro' => {
        'kli' => 'guj',
        'sense' => 'for, on the side of'
    },
    'pre' => {
        'kli' => 'krim',
        'sense' => 'before, in front'
    },
    'pseudo' => {
        'kli' => 'som',
        'sense' => 'fake, false, misrepresent'
    },
    're' => {
        'kli' => 'gul',
        'sense' => 'again'
    },
    'self' => {
        'kli' => 'ag',
        'sense' => 'self, self-sufficient'
    },
    'sep' => {
        'kli' => "lis",
        'sense' => 'divied, pull apart'
    },
    'soci' => {
        'kli' => "dat",
        'sense' => 'having to do with society'
    },
    'sub' => {
        'kli' => "om",
        'sense' => 'below'
    },
    'sup' => {
        'kli' => "om",
        'sense' => 'below, under'
    },
    'super' => {
        'kli' => "'os",
        'sense' => 'above, higher'
    },
    'supra' => {
        'kli' => "'os",
        'sense' => 'above, higher'
    },
    'sur' => {
        'kli' => "'os",
        'sense' => 'above, higher'
    },
    'ultra' => {
        'kli' => "'os",
        'sense' => 'above, higher'
    },
    'tele' => {
        'kli' => 'kuk',
        'sense' => 'distance, range, from a distance'
    },
    'trans' => {
        'kli' => 'rats',
        'sense' => 'through, across'
    },
    'un' => {
        'kli' => 'sus',
        'sense' => 'not, against'
    },
    'uni' => {
        'kli' => "mev",
        'sense' => 'one, together, united'
    },
    'under' => {
        'kli' => 'om',
        'sense' => 'lower, lesser, under, beneath'
    },
    'up' => {
        'kli' => "'os",
        'sense' => 'greater, higher'
    },
    'with' => {
        'kli' => 'sus',
        'sense' => 'against, withstand'
    }
}
@english_suffixes = {
   'an' => {
        'kli' => "yi'",
        'sense' => 'one who does'
    }, 
    'ance' => {
        'kli' => "jub",
        'sense' => 'action of state of'
    },
    'ancy' => {
        'kli' => "jub'",
        'sense' => 'state, quality, or capacity'
    },
    'ant' => {
        'kli' => "si'",
        'sense' => 'something that does, performs'
    },
    'ard' => {
        'kli' => "dokjo",
        'sense' => 'characterized as, like'
    },
    'ary' => {
        'kli' => "dokjo",
        'sense' => 'resemble, like'
    },
    'cide' => {
        'kli' => 'hotoh',
        'sense' => 'kill'
    },
    'ent' => {
        'kli' => "si'",
        'sense' => 'something that does, performs'
    },
    'fold' => {
        'kli' => "dokjir",
        'sense' => 'in a manner marked by, fourfold'
    },
    'ful' => {
        'kli' => "boh",
        'sense' => 'filled, full with'
    },
    'fy' => {
        'kli' => "bakha",
        'sense' => 'make, form'
    },
    'ish' => {
        'kli' => "dokjo",
        'sense' => 'resemble, like'
    },
    'ism' => {
        'kli' => "kul",
        'sense' => 'doctrine, conduct, belief'
    },
    'ist' => {
        'kli' => "yi'",
        'sense' => 'one who does'
    },
    'ology' => {
        'kli' => "ked",
        'sense' => 'the science of'
    },
    'nomy' => {
        'kli' => "okedi",
        'sense' => 'the science of naming, having to do with names'
    },
    'onymy' => {
        'kli' => "aasi",
        'sense' => 'specified, named, or naming'
    },
    'onym' => {
        'kli' => "aasi",
        'sense' => 'specified, named, or naming'
    },
    'language' => {
        'kli' => "aase",
        'sense' => 'tool, language'
    },
}
#@alphabet = ['a','b','d','e','g','x','i','j','k','l','m','n','o','r','s','t','u','v','y']
# @alphabet = ["'", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "r", "s", "t", "u", "v", "x", "y", "z"]
# @consonants = ['b','d','g','x','j','k','l','m','n','r','s','t','v','y']
# @vowels = ['a','e','i','o','u']

@alphabet = ["'", "a", "b",  "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "r", "s", "t", "u", "v", "x", "y", "z"]
@consonants = ["'", "b", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "r", "s", "t", "v", "x", "y", "z"]
@vowels = ["a", "e", "i", "o", "u"]


#@dipthongs = ['ai','oe','ou']
@dipthongs = ["ea", "ai", "ae", "eo", "ie"]

@consonants_followed_by_a_consonant = ['kh','kl',"k'",'kr','ts',"t'",'th','sl','st','str','tch']

@all_letter_combinations = []

@consonants_followed_by_a_vowel = []
@consonants_followed_by_a_dipthong = []
(@consonants + @consonants_followed_by_a_consonant ).each do |c|
    @vowels.each do |v|
        @consonants_followed_by_a_vowel << c + v
        @all_letter_combinations << c + v
        @all_letter_combinations << v + c
    end
    @dipthongs.each do |d|
        @consonants_followed_by_a_dipthong << c + d
        @all_letter_combinations << c + d
        @all_letter_combinations << d + c
    end
end
# @tactics = {
#     'start' => {
#         'adjective' => @dipthongs + @vowels + @all_letter_combinations,
#         'noun' => @vowels + @consonants_followed_by_a_vowel + @consonants_followed_by_a_dipthong,
#         'verb' => @dipthongs + @dipthongs + @vowels + @consonants_followed_by_a_vowel ,
#         'adverb' => @dipthongs + @vowels + @consonants_followed_by_a_vowel + @consonants_followed_by_a_dipthong
#     },
#     'middle' => @consonants + @consonants_followed_by_a_consonant,
#     'end' => {
#         'adjective' => ['uv','usy','ee','as','ux','ix','ij'],
#         'noun' => ['ej','oj','un','in','yu','ta','ra'],
#         'verb' => ['al','as','azg','ez','ex','ul','az'],
#         'adverb' => ['ay','es','ut','ase','ave']
#     }
# }
@tactics = {
    'start' => {
        'adjective' => @all_letter_combinations,
        'noun' => @all_letter_combinations,
        'verb' => @all_letter_combinations ,
        'adverb' => @all_letter_combinations
    },
    'middle' => @vowels + @dipthongs,
    'end' => {
        'adjective' => ['uv','u','ee','as','ux','ix'],
        'noun' => ['ej','oj','un','in','yu','ta','ra'],
        'verb' => ['al','as','azg','ez','ex','ul','az'],
        'adverb' => ['ay','es','ut','ase','ave']
    }
}


@english_suffixes = @english_suffixes.sort_by {|e| e.first.length }
@sufs = {}
@english_suffixes.reverse.each do |e|
    @sufs[e.first] = e[1]
end
#puts @sufs.inspect
@english_prefixes = @english_prefixes.sort_by {|e| e.first.length }
@prefs = {}
@english_prefixes.reverse.each do |e|
    @prefs[e.first] = e[1]
end
#puts @prefs.inspect
def find_prefix(word)
    prefs = []
    @prefs.each do |p,d|
        if word.index(p) == 0 and word.length > p.length then
            prefs << [p,d]
        end
    end
    return nil if prefs.empty?
    return prefs
end
def find_suffix(word)
    prefs = []
    @sufs.each do |p,d|
        if word.index(p) == (word.length - p.length) and word.length > p.length then
            prefs << [p,d]
        end
    end
    return nil if prefs.empty?
    return prefs
end
def transform_word(word)
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
    word.gsub!(/([aeiou]{3})/) { |m| ( @dipthongs.include?(m) ? m : m.split(//).join("'") ) }
    return word
end
def generate_word(word,synset,pref=nil,suf=nil)
    # should look up what was done before
    pos = synset.part_of_speech.split(' ')
    part = ''
    f = false
    pos.each do |t|
        break if f
        if @tactics['start'][t] then
            begin f = @tactics['start'][t][ rand( @tactics['start'][t].length - 1 ) ] end while not f
        end
    end
    m = false
    begin m = @tactics['middle'][ rand( @tactics['middle'].length - 1 ) ] end while not m
    e = false
    pos.each do |t|
        break if e
        if @tactics['end'][t] then
            begin e = @tactics['end'][t][ rand( @tactics['end'][t].length - 1 ) ] end while not e
            part = t
        end
    end

    new_word = "#{f}#{m}#{e}"
     new_word.gsub!(/([aeiou]{3})/) { |m| ( @dipthongs.include?(m) ? m : m.split(//).join("'") ) }
    # new_word.gsub!(/([aeiou]{2})/) { |m| @dipthongs.include? m ? m : m.split(//).join("'") }
    if pref or suf and new_word.length > 6 then
        new_word = new_word[ (new_word.length / 2 - 1).floor, new_word.length ]
    end
    if pref then
        tnw = new_word + pref.last['kli']
    else
        tnw = new_word
    end
    if suf then
        tnw += suf.last['kli']
    end
    if klingon_exists?(tnw,synset) or $generated_words.include? tnw then
        puts "An identical word has been generated"
        return generate_word(word,synset)
    else
        $generated_words << tnw
    end
    return [new_word,part]
end
def do_insert(data)
    dataset = @db[:words]
    dataset.insert(data)
    puts dataset.order(:word_id).last.inspect
end
def save_word!(word)
    puts "Saving!"
    examples = []
    the_word = transform_word(word[0].join)
    in_english = word[1]
    synset = word[2]
    part_of_speech = word.last
    if exists?(in_english,synset) then
        puts "Already saved."
    end
    
    data = {:english => in_english, :klingon => the_word, :definition => synset.definition, :part_of_speech => word.last}
    do_insert(data)
    
    # dataset.insert(:english => in_english, :klingon => the_word, :definition)
    # @tenses.each do |k,t|
    #     tw = transform_word(t['template'].gsub('$word',the_word))
    #     examples << "#{tw}: #{t['definition']} "
    #     @verb_moods.each do |k,vb|
    #         tw = transform_word(vb['template'].gsub('$word',the_word))
    #         tw = t['template'].gsub('$word',tw)
    #         examples << "\t#{tw}: #{vb['explanation']} "
    #     end
    # end
    # examples.each do |example|
    #     puts example
    # end
end
def save(word,synset,suggestions,num)
    new_word = suggestions[num - 1]
    puts "Saving: #{word} = #{new_word[0][0]}"
    part_of_speech = new_word.last
    puts "POS: #{part_of_speech}"
    #print "Yes?: "
    #inp = gets.chomp
    #if (inp == 'y') then
        save_word!(new_word)
    #else
    #    puts "Canceled"
    #end
end

def display_suggestions(suggestions)
    puts "Display suggestions called"
    groups = {}
    i = 1
    suggestions.each do |s|
        g = s[4].to_s
        groups[g] ||= []
        groups[g] << {:id => i, :suggestion => s}
        i += 1
    end
    groups.each do |g,sug|
        g = g.to_i + 1
        puts "Group: #{g}"
        sug.each do |elem|
            i = elem[:id]
            s = elem[:suggestion]
            the_word = transform_word(s[0].join)
            puts "\t - #{i}. #{the_word} #{s.last}  '#{s[1]}'  #{s[3]} #{s[2].definition}"
        end
    end
end

def lookup(word)
    Lookup.new(@db).find(word)
end

def accept_or_reject(word,synset,suggestions)
    puts "\tSuggestions"
    
    return if suggestions.empty?
    display_suggestions(suggestions)
    begin
        print "Accept(a), Retry(r), Save(s), Done(d), Suggest(n): "
        inp = gets.chomp
        if inp == 'r' then
            $generated_words = []
            display_word(word,synset)
            return
        elsif inp == 'n' then
            print "Suggest(word,pos): "
            Lookup.new(@db).create_word
            return
        elsif inp.include? 'l ' then
            res = inp.scan(/l (.*)/)
            lookup(res[0][0]) if res
        elsif inp.include? 's ' then
            num = inp.scan(/(\d+)/)
            puts num.inspect
            if num then
                num.each do |n|
                    puts 'Saving ' + n[0].to_s
                    save(word,synset,suggestions,n[0].to_i)
                end
            end
            accept_or_reject(word,synset,suggestions)
            return
        end
    end while inp != 'd'
    return
end
def has_pos?(suggestions,pos)
    suggestions.each do |s|
        return true if s.last == pos
        return true if pos.kind_of? Array and s.last == pos.first
    end
    return false
end
def exists?(word,synset)
    dataset = @db[:words]
    if synset.part_of_speech.split(" ").kind_of? Array then
        pos = synset.part_of_speech.split(" ").first
    else
        pos = synset.part_of_speech
    end
    #puts "Looing for: eng: #{word} pos: #{pos} defn: #{synset.definition}"
    tf = dataset.where(:english => word, :part_of_speech => pos, :definition => synset.definition).any?
    if tf then
        #puts "#{word} exists #{synset.definition}."
    end
    return tf
end
def klingon_exists?(word,synset)
    dataset = @db[:words]
    if synset.part_of_speech.kind_of? Array then
        pos = synset.part_of_speech.first
    else
        pos = synset.part_of_speech
    end
    tf = dataset.where(:klingon => word).any?
    return tf
end
def get_naked_word(word,prefs,sufs)
    tword = word
    if prefs then
        tword = word[ prefs.first.first.length, word.length - 1]
    end
    #puts "after prefs tword is #{tword}"
    if sufs then
        tword = word[ 0, word.index(sufs.first.first)]
    end
    #puts "after sufs tword is #{tword}"
    if tword.index('ed') == tword.length - 2 then
        tword = tword[0, tword.length - 2]
    end
    #puts "After ed check #{tword}"
    if tword[tword.length - 1] == 's' then
        tword = tword[0, tword.length - 1]
    end
    #puts "After s check #{tword}"
    return tword

end
def get_roots(word,suggestions)

    return suggestions
end
def get_suggestion(word,syn=nil,syn_group)
    syn = @lexicon[word]
    prefs = find_prefix(word)
    sufs = find_suffix(word)
    id = 0
    suggestions = []
    naked_word = get_naked_word(word,prefs,sufs)
    if prefs then  
        prefs.each do |pref|
            if sufs then
                sufs.each do |suf|
                    remainder = word[ pref.first.length, word.length - 1]
                    new_word = generate_word(remainder,syn,pref,suf)
                    suggestions[id] = format_suggestion(new_word,syn,pref,suf,word,syn_group,' gs-new ')
                    id += 1
                end
            else
                remainder = word[ pref.first.length, word.length - 1]
                new_word = generate_word(remainder,syn,pref)
                suggestions[id] = format_suggestion(new_word,syn,pref,nil,word,syn_group,' gs-new ')
                id += 1
            end
            
        end
    else
        if sufs then
            sufs.each do |suf|
                remainder = word[ suf.first.length, word.length - 1]
                new_word = generate_word(remainder,syn,nil,suf)
                suggestions[id] = format_suggestion(new_word,syn,nil,suf,word,syn_group,' gs-new ')
                id += 1
            end
        else
            new_word = generate_word(word,syn)
            suggestions[id] = format_suggestion(new_word,syn,nil,nil,word,syn_group,' gs-new ')
            id += 1   
        end   
    end
    return suggestions
end
def format_suggestion(new_word,syn,pref,suf,word,syn_group,type)
   if pref and suf then
       return [
            ["#{new_word[0]}","#{pref.last['kli']}","#{suf.last['kli']}"],
            word,
            syn,
            type,
            syn_group,
            new_word[1]
        ]
    elsif pref and not suf then
        return [
            ["#{new_word[0]}","#{pref.last['kli']}"],
            word,
            syn,
            type,
            syn_group,
            new_word[1]
        ]
    elsif not pref and suf then
        return [
            ["#{new_word[0]}","#{suf.last['kli']}"],
            word,
            syn,
            type,
            syn_group,
            new_word[1]
        ]
    elsif not pref and not suf then
        return [
            ["#{new_word[0]}"],
            word,
            syn,
            type,
            syn_group,
            new_word[1]]
    end
end
def get_pos(syn)
    syn.part_of_speech.split(' ').first
end
def display_word(word,synset)
    puts "The word is [#{word}]"
    dataset = @db[:words]
    prefs = find_prefix(word)
    sufs = find_suffix(word)
    
    suggestions = []
    id = 0
    syn_group = 0
    synset.each do |syn|
        if exists?(word,syn) then
            #puts "Skipping"
            next
        end
        #puts "\tPart of speach: #{syn.part_of_speech} #{syn.definition}"
        #puts "\t\t" + syn.words.join(', ')
        if prefs then  
            prefs.each do |pref|
                if sufs then
                    sufs.each do |suf|
                        remainder = word[ pref.first.length, word.length - 1]
                        new_word = generate_word(remainder,syn,pref,suf)
                        suggestions[id] = format_suggestion(new_word,syn,pref,suf,word,syn_group,' new ')
                        id += 1
                    end
                else
                    remainder = word[ pref.first.length, word.length - 1]
                    new_word = generate_word(remainder,syn,pref)
                    suggestions[id] = format_suggestion(new_word,syn,pref,nil,word,syn_group,' new ')
                    id += 1
                end
                
            end
        else
            if sufs then
                sufs.each do |suf|
                    remainder = word[ suf.first.length, word.length - 1]
                    new_word = generate_word(remainder,syn,nil,suf)
                    suggestions[id] = format_suggestion(new_word,syn,nil,suf,word,syn_group,' new ')
                    id += 1
                end
            else
                new_word = generate_word(word,syn)
                suggestions[id] = format_suggestion(new_word,syn,nil,nil,word,syn_group,' new ')
                id += 1   
            end   
        end
        
        syn.hyponyms.each do |h|
            #puts "hyponyms found"
            #puts h.inspect
            h.words.each do |w|
                #puts "\t\t\t\tHyponym: #{w}"
                if w.lemma != word then
                    if dataset.where(:english => w.lemma).any? then
                        
                        dataset.where(:english => w.lemma).each do |dw|
                            #dsyn = @lexicon[w.lemma]
                            dsyn = DummySynset.new(word, dw[:part_of_speech], dw[:definition])
                            suggestions[id] = format_suggestion( [ dw[:klingon],get_pos(syn) ], syn, nil, nil, word, syn_group," hypo-exists(#{w.lemma}) ")
                            #suggestions[id] = [,w.lemma, dsyn,,dw[:part_of_speech]]
                            id += 1
                        end
                    else
                        suggestions += get_suggestion(w.lemma,syn, syn_group)
                    end
                end
            end
        end
        syn.words.each do |w|
            #puts "\t\t\t\tSynonym: #{w.lemma}"
            if w.lemma != word then
                if dataset.where(:english => w.lemma).any? then
                    dataset.where(:english => w.lemma).each do |dw|
                        #dsyn = @lexicon[w.lemma]
                        dsyn = DummySynset.new(word, dw[:part_of_speech], dw[:definition])
                        suggestions[id] = format_suggestion( [ dw[:klingon], get_pos(syn) ], syn, nil, nil, word, syn_group, " syn-exists(#{w.lemma})")
                        #suggestions[id] = [[ dw[:klingon] ],w.lemma, dsyn,' syn-exists ',dw[:part_of_speech]]
                        id += 1
                    end
                else
                    suggestions += get_suggestion(w.lemma,syn,syn_group)
                end
            end
        end
        syn_group += 1
    end
    naked_word = get_naked_word(word,prefs,sufs)
    suggestions = get_roots(naked_word,suggestions)
    
    accept_or_reject(word,synset,suggestions)
    return
end


words = File.open("sample.txt", 'r').read.scan(/[\w]+/)

words.each do |word|
    next if word.length < 4
    $generated_words = []
    synset = @lexicon.lookup_synsets(word)
    if not synset.empty? then
        display_word(word,synset)
    else
        word = get_naked_word(word,nil,nil)
        synset = @lexicon.lookup_synsets(word)
        display_word(word,synset) if synset
    end
end
