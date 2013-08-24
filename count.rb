letters = File.open('aase.txt','r').read.downcase.gsub(/[,\-]/,'').split("\n").join().gsub(' ','').split(//).uniq!.sort
puts "@alphabet = " + letters.inspect
puts "@consonants = " + letters.select {|l| not "aeiou".split(//).include? l }.inspect
puts "@vowels = " + letters.select {|l| "aeiou".split(//).include? l }.inspect

dips = File.open('aase.txt','r').read.downcase.gsub(/[,\-]/,'').split("\n").join().gsub(' ','').scan(/[aeiou]{2}/).uniq!.select { |d| d.split(//)[0] != d.split(//)[1] }
puts "@dipthongs = " + dips.inspect