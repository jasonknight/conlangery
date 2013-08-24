#!/usr/bin/env ruby
require 'wordnet'
require 'sequel'
require './word.rb'
@db = Sequel.sqlite('kli.sqlite3')
@lex = WordNet::Lexicon.new
@word = ARGV[0]
@base = ARGV[1]
puts "Searching #{@word}"
synsets = @lex.lookup_synsets(@word, WordNet::Noun,1)
base_synsets = @lex.lookup_synsets( @base, WordNet::Noun, 7)
synsets.each do |synset|
	synset.words.each do |word|
		Word.inspect_wordnet(word)
	end
end