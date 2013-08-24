# coding: UTF-8
@reps = {:ng => 'ŋ', :ae => 'æ',:kh => 'kh',:oe => 'œ',:ea => 'ea',:ts => 'ts',:aa => 'á',:ee => 'é', :oo => 'ó'}
def clean(new_word)
    @reps.each do |k,v|
        new_word = new_word.gsub(/#{k.to_s}/,v.to_s)
    end
    return new_word
end
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

@english_prefixes.each do |prefix,defn|
    if defn['kli'].length <= 3 then
        puts "#{prefix}- & N-#{clean(defn['kli'])} & #{defn['sense']} \\\\"
    else
        puts "#{prefix}- & #{clean(defn['kli'])} N & #{defn['sense']} \\\\"
    end
end

puts "\n\n\n"

@english_suffixes.each do |suffix,defn|
    if defn['kli'].length <= 3 then
        puts "-#{suffix} & N-#{clean(defn['kli'])} & #{defn['sense']} \\\\"
    else
        puts "-#{suffix} & #{clean(defn['kli'])} N & #{defn['sense']} \\\\"
    end
end