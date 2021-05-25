class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
#   scope :with_title_regexp, -> (pattern) { with_regexp(columns_hash['title'].name, pattern) }
#   scope :with_artist_regexp, -> (pattern) { with_regexp(columns_hash['artist'].name, pattern) }
#   scope :with_genre_regexp, -> (pattern) { with_regexp(columns_hash['genre'].name, pattern) }
#   scope :with_key_regexp, -> (pattern) { with_regexp(columns_hash['key'].name, pattern) }
#   scope :with_section_regexp, -> (pattern) { with_regexp(columns_hash['section_numbar'].name, pattern) }
# #  scope :with_content_regexp, -> (pattern) { with_regexp(columns_hash['content'].name, pattern) }
#   scope :with_regexp, -> (column, pattern) { where("`#{table_name}`.`#{column}` REGEXP ?", pattern) }
end
