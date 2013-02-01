module DoubleDouble
  class TransactionType < ActiveRecord::Base
    self.table_name = 'double_double_transaction_types'
    
    has_many :transactions
    attr_accessible :description

    validates :description, length: { minimum: 6 }, presence: true, uniqueness: true

    def self.of description_given
      TransactionType.where(description: description_given.to_s).first
    end
  end

  class UnassignedTransactionType
    class << self
      def description
        'unassigned'
      end
    end
  end
end