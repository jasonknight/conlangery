require 'sequel'

module Target
  DB = Sequel.sqlite('data/target.sqlite')
  DB.create_table :words do
    primary_key :word_id
    column :english, :string
    column :target_language, :string
    column :definition, :text
    column :wordnet_wordid, :integer
    column :wordnet_synsetid, :integer
    column :part_of_speech, :string
    index :word_id
    index :wordnet_synsetid
    index :target_language
    index :english
  end if not DB.table_exists? :words
  DB.create_table :synonyms do
    primary_key :synonym_id
    column :word1_id, :integer
    column :word2_id, :integer
    index :word1_id
    index :word2_id
  end if not DB.table_exists? :synonyms

  def self.count
    return DB[:words].with_sql('select count(DISTINCT target_language) as num_records from words').first[:num_records]
  end
  def self.count_english
    return DB[:words].with_sql("select count(DISTINCT english) as num_records from words where english NOT LIKE '% %'").first[:num_records]
  end
  def self.count_verbs
    return DB[:words].with_sql("select count(*) as num_records from words where part_of_speech = 'verb'").first[:num_records]
  end
  def self.count_nouns
    return DB[:words].with_sql("select count(*) as num_records from words where part_of_speech = 'noun'").first[:num_records]
  end
  def self.count_adverbs
    return DB[:words].with_sql("select count(*) as num_records from words where part_of_speech = 'adverb'").first[:num_records]
  end
  def self.count_adjectives
    return DB[:words].with_sql("select count(*) as num_records from words where part_of_speech = 'adjective'").first[:num_records]
  end
  def self.total_words
    return DB[:words].with_sql('select count(*) as num_records from words').first[:num_records]
  end
  class Synonym < Sequel::Model( DB[:synonyms] )
    set_primary_key :synonym_id
  end
  class Word < Sequel::Model( DB[:words] )
    set_primary_key :word_id
    many_to_many :synonyms,
                 :class => 'Target::Word',
                 :join_table => :synonyms,
                 :left_key   => :word1_id,
                 :right_key  => :word2_id
    many_to_many :inverse_synonyms,
                 :class => 'Target::Word',
                 :join_table => :synonyms,
                 :left_key   => :word2_id,
                 :right_key  => :word1_id
    def self.from_suggestion(s)
      w = {}
      [:english, :target_language, :wordnet_synsetid, :wordnet_wordid, :definition, :part_of_speech].each do |key|
        w[key] = s[key].to_s
      end
      Word.insert(w)
    end
    def self.from_suggestion_as(s,as_s)
      w = {}
      [:english, :target_language, :wordnet_synsetid, :wordnet_wordid, :definition, :part_of_speech].each do |key|
        w[key] = s[key].to_s
      end
      w[:target_language] = as_s[:target_language]
      Word.insert(w)
    end
    def self.from_suggestion_as_cognate(s)
      w = {}
      [:english, :target_language, :wordnet_synsetid, :wordnet_wordid, :definition, :part_of_speech].each do |key|
        w[key] = s[key].to_s
      end
      w[:target_language] = s[:english]
      Word.insert(w)
    end
    def has_synonym(wid)
      self.synonyms.each do |a_synonym|
        if a_synonym.word_id == wid then
          return true
        end
      end
      self.inverse_synonyms.each do |a_synonym|
        if a_synonym.word_id == wid then
          return true
        end
      end
      return false
    end
    def remove_syn_connections
      DB[:synonyms].where( :word1_id => self.word_id).delete
      DB[:synonyms].where( :word2_id => self.word_id).delete
    end
    def remove_completely
      self.synonyms.each do |a_synonym|
        a_synonym.delete
      end
      self.inverse_synonyms.each do |a_synonym|
        a_synonym.delete
      end
    end
  end

end