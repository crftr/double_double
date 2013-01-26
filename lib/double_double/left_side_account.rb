module DoubleDouble
  class LeftSideAccount < Account
    def balance(hash = {})
      if contra
        credits_balance(hash) - debits_balance(hash)
      else
        debits_balance(hash) - credits_balance(hash)
      end
    end
  end
end