module DoubleDouble
  # The Revenue class is an account type used to represents increases in owners equity.
  #
  # === Normal Balance
  # The normal balance on Revenue accounts is a *Credit*.
  #
  # @see http://en.wikipedia.org/wiki/Revenue Revenue
  #
  # @author Michael Bulat
  class Revenue < Account

    # The balance of the account.
    #
    # Revenue accounts have normal credit balances, so the debits are subtracted from the credits
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