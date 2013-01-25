module DoubleDouble
  # The CreditAmount class represents credit entries in the transaction journal.
  #
  # @example
  #     credit_amount = DoubleDouble::CreditAmount.new(:account => revenue, :amount => 1000)
  #
  class CreditAmount < Amount
  end
end