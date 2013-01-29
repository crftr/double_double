module DoubleDouble
  class NormalDebitAccount < Account
    def balance(hash = {})
      child_account_balance(true, hash)
    end
  end
end