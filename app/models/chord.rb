class Chord < ApplicationRecord
  belongs_to :song
  
  scope :with_content_regexp, -> (pattern) { with_regexp(columns_hash['content'].name, pattern) }
  scope :with_regexp, -> (column, pattern) { where("`#{table_name}`.`#{column}` REGEXP ?", pattern) }

  has_many :fields
  accepts_nested_attributes_for :fields
end
