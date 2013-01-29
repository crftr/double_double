module DoubleDouble
  class NormalCreditAccount < Account
    def balance(hash = {})
      child_account_balance(false, hash)
    end
  end
end