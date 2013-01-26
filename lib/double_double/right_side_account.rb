module DoubleDouble
  class RightSideAccount < Account
    def balance(hash = {})
      if contra
        debits_balance(hash) - credits_balance(hash)
      else
        credits_balance(hash) - debits_balance(hash)
      end
    end
  end
end