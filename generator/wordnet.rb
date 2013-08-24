module WordNet
  DB = Sequel.sqlite('data/wordnet30.sqlite')
  WORDTYPES = {
    "n" => :noun,
    "v" => :verb,
    "a" => :adjective,
    "r" => :adverb,
    "s" => :adjective,
  }
  class SumoTerm < Sequel::Model( :sumoterms )
      set_primary_key :sumoid
      many_to_many :synsets,
                   :join_table => :sumomaps,
                   :left_key   => :sumoid,
                   :right_key  => :synsetid
  end
  class LexicalLink < Sequel::Model( :lexlinks )
    set_primary_key [:word1id, :synset1id, :word2id, :synset2id, :linkid]

    ##
    # The WordNet::Sense the link is pointing *from*.
    many_to_one :origin,
      :class       => :"WordNet::Sense",
      :key         => :synset1id,
      :primary_key => :synsetid

    ##
    # The WordNet::Synset the link is pointing *to*.
    one_to_many :target,
      :class       => :"WordNet::Synset",
      :key         => :synsetid,
      :primary_key => :synset2id
  end
  class SemanticLink < Sequel::Model( :semlinks )
    set_primary_key [:synset1id, :synset2id, :linkid]

    many_to_one :origin,
      :class       => :"WordNet::Synset",
      :key         => :synset1id,
      :primary_key => :synsetid

    one_to_one :target,
      :class       => :"WordNet::Synset",
      :key         => :synsetid,
      :primary_key => :synset2id,
      :eager       => :words
  end
  class Sense < Sequel::Model ( :senses )
    TYPES = [
      'none',
      'noun',
      'verb',
      'adjective',
      'adverb',
      'adjective'
    ]
    set_primary_key :senseid

    many_to_one :synset, :key => :synsetid
    many_to_one :word, :key => :wordid
    one_to_many :lexlinks,
                :class       => :"WordNet::LexicalLink",
                :key         => [ :synset1id, :word1id ],
                :primary_key => [ :synsetid, :wordid ]
  end
  class Morph < Sequel::Model( :morphs )
    set_primary_key :morphid
    many_to_many :words,
                 :join_table => :morphmaps,
                 :right_key  => :wordid,
                 :left_key   => :morphid
  end
  class Synset <  Sequel::Model( :synsets )
    set_primary_key :synsetid

    many_to_many :words,
      :join_table  => :senses,
      :left_key    => :synsetid,
      :right_key   => :wordid

    one_to_many :senses,
      :key         => :synsetid,
      :primary_key => :synsetid


    one_to_many :semlinks,
      :class       => :"WordNet::SemanticLink",
      :key         => :synset1id,
      :primary_key => :synsetid,
      :eager       => :target

    many_to_one :semlinks_to,
      :class       => :"WordNet::SemanticLink",
      :key         => :synsetid,
      :primary_key => :synset2id

    many_to_many :sumo_terms,
      :join_table  => :sumomaps,
      :left_key    => :synsetid,
      :right_key   => :sumoid
  end
  class Word < Sequel::Model( :words )
    set_primary_key :wordid
    one_to_many :senses,
                :key => :wordid,
                :primary_key => :wordid
    many_to_many :synsets,
                 :join_table => :senses,
                 :left_key => :wordid,
                 :right_key => :synsetid
    many_to_many :morphs,
                 :join_table => :morphmaps,
                 :left_key => :wordid,
                 :right_key => :morphid
    def definitions
      return @defs if @defs
      @defs = {}
      self.synsets.each do |syn|
        @defs[ WordNet::WORDTYPES[syn.pos] ] ||= []
        @defs[ WordNet::WORDTYPES[syn.pos] ] << {:syn => syn, :defn => syn.definition, :wordnet_wordid => self.wordid}
      end
      return @defs
    end
  end
end