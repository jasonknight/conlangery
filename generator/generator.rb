#!/usr/bin/env ruby
require 'sequel'
# This comes after so that we have established the connection to the db
require './wordnet.rb'
require './phonotactics.rb'
require './lexor.rb'
require './interface.rb'

alphabet = ["'", "a", "b",  "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "r", "s", "t", "u", "v", "x", "y", "z"]
#consonants = ["'", "b", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "r", "s", "t", "v", "x", "y", "z"]
consonants = [ "b", "d", "f", "g", "h", "j", "k", "l", "m", "p", "r", "t", "v", ]
#consonants_followed_by_a_consonant = ['kh','kl',"k'",'kr','ts',"t'",'th','sl','st','str','pr','ps','ng',sk','sr']
consonants_followed_by_a_consonant = ['kh','kl',"k'",'kr','ts',"t'",'th','pr','ps','ng']

vowels = ["a", "e", "i", "o", "u"]


#@dipthongs = ['ai','oe','ou']
diphthongs = ["ea", "ai", "ae", "eo", "ie"]
double_vowels = ['aa','ee']



     middle_syllables = []
     vowels.each do |v|
      middle_syllables << v
      consonants.each do |c|
        next if [:x,:k].include? c.to_sym
        middle_syllables << v + c
      end
    end
    diphthongs.each do |d|
       middle_syllables << d
      consonants.each do |c|
        next if [:x,:k,:b,:s,:f,:z].include? c.to_sym
        middle_syllables << d + c
      end
    end

    #middle_syllables += ['akk','ukk','ath','ith','uth','urk','est','ast','ust','ang','eng','agy','ugy','antr','entr','untr','ant','unt','ent']
    #middle_syllables += ['akk','ukk','ath','ith','uth','urk','est','ast','ust','ang','eng','agy','ugy','antr','entr','untr','ant','unt','ent']
    [:kk,:tt,:kh,:kr,:kl,:sh,:st,:ntr,:nt,:th,:tl,:gy, :rf, :rs,:rk,:rt, :vd,:zh,:zn,:mb,:ld,:pp,:yd,:yr,:yn,:ym,:syn,:sym,:ryd,:ryn,:rym,:tyd,:tyn,:tyn,:tyr].each do |con|
      vowels.each do |v|
        middle_syllables << "#{v}#{con}"
        # vowels.each do |v2|
        #   middle_syllables << "#{v}#{con}#{v2}"
        # end
      end
      diphthongs.each do |v|
        middle_syllables << "#{v}#{con}"
        # diphthongs.each do |v2|
        #   middle_syllables << "#{v}#{con}#{v2}"
        # end
      end
    end
    # middle_syllables += ['akk','ukk','ath','ith','uth','urk','est','ast','ust','ang','eng','agy','ugy','antr','entr','untr','ant','unt','ent']
    beginnings = ( consonants + consonants_followed_by_a_consonant).join(',')

    verb_endings = "a,e,o,u"
    endings = ''
    tactics = Phonotactics.new
    tactics.consonants     = consonants + consonants_followed_by_a_consonant
    tactics.vowels         = vowels + diphthongs
    
    tactics.set_verb_tactic( :start,     beginnings  )
           .set_verb_tactic( :middle,    middle_syllables.join(',') )
           .set_verb_tactic( :end,       verb_endings )

    #noun_endings = "ej,oj,an,on,ahd,arn,ahn,od,id,aht,os,ahm"
    noun_endings = "e,u,o,ej,oj,aj,ahj,ohj,a,on,ohn,uhn,un,az,azh,ahd,ahn,od,aht,ahm"
    tactics.set_noun_tactic( :start,     beginnings  )
           .set_noun_tactic( :middle,    (middle_syllables + double_vowels).join(',') )
           .set_noun_tactic( :end,       noun_endings )

    adj_endings = "e"
    tactics.set_adjective_tactic( :start,     beginnings  )
           .set_adjective_tactic( :middle,    middle_syllables.join(',') )
           .set_adjective_tactic( :end,       adj_endings )

    adv_endings = "a,e"
    tactics.set_adverb_tactic( :start,     beginnings  )
           .set_adverb_tactic( :middle,    middle_syllables.join(',') )
           .set_adverb_tactic( :end,       adv_endings )

    tactics.set_other_tactic( :start,     beginnings )
           .set_other_tactic( :middle,    middle_syllables.join(',') )
           .set_other_tactic( :end,       adv_endings )

    [:start,:middle,:end].each do |position|
      [:noun, :verb, :adjective, :adverb, :other].each do |pos|
        tactics.set_tactic( pos, "#{position}_max_len".to_sym, 1 )
        tactics.set_tactic( pos, "#{position}_min_len".to_sym, 1 )
      end
    end

lexor = Lexor.new(tactics)
int = Interface.new(tactics,lexor,ARGV[0])

