module DoubleDouble
  # The Expense class is an account type used to represents assets or services consumed in the generation of revenue.
  #
  # === Normal Balance
  # The normal balance on Expense accounts is a *Debit*.
  #
  # @see http://en.wikipedia.org/wiki/Expense Expenses
  #
  # @author Michael Bulat
  class Expense < Account

    # The balance of the account.
    #
    # Expenses have normal debit balances, so the credits are subtracted from the debits
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