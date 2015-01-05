module DoubleDouble
  # The DebitAmount class represents debit entries in the entry journal.
  #
  # @example
  #     debit_amount = DoubleDouble::DebitAmount.new(account: "cash", amount: 1000)
  #
  class DebitAmount < Amount
  end
end