require 'awesome_print'
class Lexor
  attr_accessor :tactics, :info_for
  def initialize(t=nil)
    @tactics = t
    @info_for = {}
    @tactics.tactics_for.each do |t,h|
      @info_for[t] ||= {}
      [:start, :middle, :end ].each do |position|
        if h[position] then
          tmp_letters = h[position].split(',')
          # uniq deletes the elements if they are already uniq, which is dumb
          t_uniq = tmp_letters.uniq
          t_uniq = tmp_letters if t_uniq.nil?
          @info_for[t][position] = { :letters => t_uniq }
          @info_for[t]["#{position}_max_len".to_sym] = h["#{position}_max_len".to_sym]
          @info_for[t]["#{position}_min_len".to_sym] = h["#{position}_min_len".to_sym]
        end
      end
    end
    #ap @info_for
  end
  def get_letters_for_position( pos, position, number_of_chars_to_select)
    #puts "pos is: #{pos} position is"
    if position == :middle then
      number_of_chars_to_select = 1
    end
    letters = ''
    (number_of_chars_to_select).times do 
      letters += @info_for[ pos ][ position ][:letters][ rand( @info_for[ pos ][ position ][:letters].length ) ] if @info_for[ pos ][ position ][:letters].length > 0
    end
    return letters
  end
  def generate_word(pos)
    new_word = {
      :start => '',
      :middle => '',
      :end => ''
    }

    [:start,:middle,:end].each do |position|
      max_start_chars = @info_for[pos][ "#{position}_max_len".to_sym ]
      min_start_chars = @info_for[pos][ "#{position}_min_len".to_sym ]
      number_of_chars_to_select = 1 #rand(min_start_chars..max_start_chars)
      #puts "Number of chars: #{number_of_chars_to_select}"
      new_word[ position ] = get_letters_for_position( pos, position, number_of_chars_to_select)
    end
    if @tactics.validate(pos,new_word) != true then
      generate_word(pos)
    else
      return new_word
    end
  end

  def merge_words(pos,base_word,target_word)
    new_word = {
      :start => base_word[:start],
      :middle => '',
      :end => base_word[:end]
    }
    begin
      number_of_chars_to_select = 0
      new_word[:middle] = get_letters_for_position( pos, :middle, 1)
      puts "bw: #{base_word[:middle]} nw: #{new_word[:middle]}"
    end while base_word[:middles].include?(new_word[:middle]) == true
    return new_word
  end

end