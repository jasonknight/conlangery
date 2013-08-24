# This class details the tactics used to create phonemes for words.
class Phonotactics
  attr_accessor :tactics_for, :vowels, :consonants, :diphthongs
  def initialize
    # Here we add regexes to verify a choice
    @tactics_for = {
      :verb => {
        :start => nil,
        :middle => nil,
        :end => nil,
        :reject_start_when => nil,
        :reject_middle_when => nil,
        :reject_end_when => nil,
        :start_max_len => 2,
        :middle_max_len => 2,
        :end_max_len => 3,
        :start_min_len =>1,
        :middle_min_len => 1,
        :end_min_len => 1
      },
      :noun => {
        :start => nil,
        :middle => nil,
        :end => nil,
        :reject_start_when => nil,
        :reject_middle_when => nil,
        :reject_end_when => nil,
        :start_max_len => 2,
        :middle_max_len => 2,
        :end_max_len => 3,
        :start_min_len =>1,
        :middle_min_len => 1,
        :end_min_len => 1
      },
      :adjective => {
        :start => nil,
        :middle => nil,
        :end => nil,
        :reject_start_when => nil,
        :reject_middle_when => nil,
        :reject_end_when => nil,
        :start_max_len => 2,
        :middle_max_len => 2,
        :end_max_len => 3,
        :start_min_len =>1,
        :middle_min_len => 1,
        :end_min_len => 1
      },
      :adverb => {
        :start => nil,
        :middle => nil,
        :end => nil,
        :reject_start_when => nil,
        :reject_middle_when => nil,
        :reject_end_when => nil,
        :start_max_len => 2,
        :middle_max_len => 2,
        :end_max_len => 3,
        :start_min_len =>1,
        :middle_min_len => 1,
        :end_min_len => 1
      },
      :other => {
        :start => nil,
        :middle => nil,
        :end => nil,
        :reject_start_when => nil,
        :reject_middle_when => nil,
        :reject_end_when => nil,
        :start_max_len => 2,
        :middle_max_len => 2,
        :end_max_len => 3,
        :start_min_len =>1,
        :middle_min_len => 1,
        :end_min_len => 1
      }
    }
  end
  def set_tactic(pos,position,value)
    case pos
    when :verb then set_verb_tactic(position,value)
    when :noun then set_noun_tactic(position,value)
    when :adverb then set_adverb_tactic(position,value)
    when :adjective then set_adjective_tactic(position,value)
    when :other then set_other_tactic(position,value)
    else
      puts 'No such word type'
    end
  end
  def set_verb_tactic(position,reg)
    @tactics_for[:verb][position] = reg
    return self
  end
  def set_noun_tactic(position,reg)
    @tactics_for[:noun][position] = reg
    return self
  end
  def set_adjective_tactic(position,reg)
    @tactics_for[:adjective][position] = reg
    return self
  end
  def set_adverb_tactic(position,reg)
    @tactics_for[:adverb][position] = reg
    return self
  end
  def set_other_tactic(position,reg)
    @tactics_for[:other][position] = reg
    return self
  end
  def validate(type,word_parts)
    the_start = word_parts[:start]
    the_end = word_parts[:end]
    the_middle = word_parts[:middle]

    #puts "Start: #{the_start}, Middle: #{the_middle}, End: #{the_end}"
    if @tactics_for[type][:reject_start_when] and the_start.match( @tactics_for[type][:reject_start_when] ) then 
      #puts "Failed for start"
      return :start
    end
    if @tactics_for[type][:reject_middle_when] and  the_middle.match( @tactics_for[type][:reject_middle_when] ) then 
      #puts "Failed for middle"
      return :middle
    end
    if @tactics_for[type][:reject_end_when] and the_end.match( @tactics_for[type][:reject_end_when] ) then 
      #puts "Failed for end"
      return :end
    end
    return true
  end
end