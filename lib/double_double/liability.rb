module DoubleDouble
  # The Liability class is an account type used to represents debts owed to outsiders.
  #
  # === Normal Balance
  # The normal balance on Liability accounts is a *Credit*.
  #
  # @see http://en.wikipedia.org/wiki/Liability_(financial_accounting) Liability
  #
  class Liability < Account

    # The balance of the account.
    #
    # Liability accounts have normal credit balances, so the debits are subtracted from the credits
    # unless this is a contra account, in which credits are subtracted from debits
    #
    # @return [Money] The value balance
    def balance(hash = {})
      if contra
        debits_balance(hash) - credits_balance(hash)
      else
        credits_balance(hash) - debits_balance(hash)
      end
    end
  end
end