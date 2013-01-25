module DoubleDouble
  # The Asset class is an account type used to represents resources owned by the business entity.
  #
  # === Normal Balance
  # The normal balance on Asset accounts is a *Debit*.
  #
  # @see http://en.wikipedia.org/wiki/Asset Assets
  #
  class Asset < Account

    # The balance of the account.
    #
    # Assets have normal debit balances, so the credits are subtracted from the debits
    # unless this is a contra account, in which debits are subtracted from credits
    #
    # @return [Money] The value balance
    def balance(hash = {})
      if contra
        credits_balance(hash) - debits_balance(hash)
      else
        debits_balance(hash) - credits_balance(hash)
      end
    end
  end
end