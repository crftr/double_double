module DoubleDouble
  class EntryType < ActiveRecord::Base
    self.table_name = 'double_double_entry_types'
    
    has_many :entries

    validates :description, length: { minimum: 6 }, presence: true, uniqueness: true

    def self.of description_given
      EntryType.where(description: description_given.to_s).first
    end

    def to_s
      description
    end
  end

  class UnassignedEntryType
    class << self
      def description
        'unassigned'
      end
    end
  end
end