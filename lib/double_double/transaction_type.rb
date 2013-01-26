module DoubleDouble
  class TransactionType < ActiveRecord::Base
    self.table_name = 'double_double_transaction_types'
    
    has_many :transactions
    attr_accessible :number, :description

    validates_numericality_of :number,      greater_than: 0
    validates_length_of       :description, minimum: 6
  end
end