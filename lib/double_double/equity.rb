module DoubleDouble
  # The Equity class is an account type used to represents owners rights to the assets.
  #
  # === Normal Balance
  # The normal balance on Equity accounts is a *Credit*.
  #
  # @see http://en.wikipedia.org/wiki/Equity_(finance) Equity
  #
  # @author Michael Bulat
  class Equity < Account

    # The balance of the account.
    #
    # Equity accounts have normal credit balances, so the debits are subtracted from the credits
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