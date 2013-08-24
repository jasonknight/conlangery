# coding: UTF-8
class Conjugator
	attr_accessor :word, :reps
	def initialize(word)
		@word = word
		@reps = {:ng => 'ŋ', :ae => 'æ',:kh => 'kh',:oe => 'œ',:ea => 'ea',:ts => 'ts',:aa => 'á',:ee => 'é', :oo => 'ó'}
	end
	def first_person
		return @word.gsub(/(ul|al|ik|atl)$/) do |suf|
			"esa"
		end
	end
end