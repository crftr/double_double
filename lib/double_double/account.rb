module DoubleDouble
  # The Account class represents accounts in the system. Each account must be subclassed as one of the following types:
  #
  #   TYPE        | NORMAL BALANCE    | DESCRIPTION
  #   --------------------------------------------------------------------------
  #   Asset       | Debit             | Resources owned by the Business Entity
  #   Liability   | Credit            | Debts owed to outsiders
  #   Equity      | Credit            | Owners rights to the Assets
  #   Revenue     | Credit            | Increases in owners equity
  #   Expense     | Debit             | Assets or services consumed in the generation of revenue
  #
  # Each account can also be marked as a "Contra Account". A contra account will have it's
  # normal balance swapped. For example, to remove equity, a "Drawing" account may be created
  # as a contra equity account as follows:
  #
  #   DoubleDouble::Equity.create(name: "Drawing", number: 2002, contra: true)
  #
  # At all times the balance of all accounts should conform to the "accounting equation"
  #   DoubleDouble::Assets = Liabilties + Owner's Equity
  #
  # Each sublclass account acts as it's own ledger. See the individual subclasses for a
  # description.
  #
  # @abstract
  #   An account must be a subclass to be saved to the database. The Account class
  #   has a singleton method {trial_balance} to calculate the balance on all Accounts.
  #
  # @see http://en.wikipedia.org/wiki/Accounting_equation Accounting Equation
  # @see http://en.wikipedia.org/wiki/Debits_and_credits Debits, Credits, and Contra Accounts
  #
  class Account < ActiveRecord::Base
    self.table_name = 'double_double_accounts'

    attr_accessible :name, :contra, :number
    
    has_many :credit_amounts
    has_many :debit_amounts
    has_many :credit_transactions, through: :credit_amounts, source: :transaction
    has_many :debit_transactions,  through: :debit_amounts,  source: :transaction

    validates_presence_of :type, :name, :number
    validates_uniqueness_of :name, :number
    validates_length_of :name, :minimum => 1

    def side_balance(is_debit, hash)
      a = is_debit ? DoubleDouble::DebitAmount.scoped : DoubleDouble::CreditAmount.scoped
      a = a.where(account_id: self.id)
      a = a.by_context(hash[:context])     if hash.has_key? :context
      a = a.by_initiator(hash[:initiator]) if hash.has_key? :initiator
      a = a.by_accountee(hash[:accountee]) if hash.has_key? :accountee
      Money.new(a.sum(:amount_cents))
    end
    
    def credits_balance(hash = {})
      side_balance(false, hash)
    end

    def debits_balance(hash = {})
      side_balance(true, hash)
    end

    # The trial balance of all accounts in the system. This should always equal zero,
    # otherwise there is an error in the system.
    #
    # @return [Money] The value balance of all accounts
    def self.trial_balance
      raise(NoMethodError, "undefined method 'trial_balance'") unless self == DoubleDouble::Account
      Asset.balance - (Liability.balance + Equity.balance + Revenue.balance - Expense.balance)
    end
    
    def self.balance
      raise(NoMethodError, "undefined method 'balance'") if self == DoubleDouble::Account
      accounts_balance = Money.new(0)
      accounts = self.all
      accounts.each do |acct|
        if acct.contra
          accounts_balance -= acct.balance
        else
          accounts_balance += acct.balance
        end
      end
      accounts_balance
    end

    def self.named account_name
      self.where(name: account_name.to_s).first
    end

    def self.numbered account_number
      self.where(number: account_number.to_i).first
    end

    protected
      # The balance method that derived Accounts utilize.
      #
      # Nornal Debit Accounts:
      # if contra { credits_balance(hash) - debits_balance(hash)  }
      # else      { debits_balance(hash)  - credits_balance(hash) }
      #
      # Normal Credit Accounts:
      # if contra { debits_balance(hash)  - credits_balance(hash) }
      # else      { credits_balance(hash) - debits_balance(hash)  }
      #
      # @return [Money] The balance of the account instance
      def child_account_balance(is_normal_debit_account, hash = {})
        raise(NoMethodError, "undefined method 'balance'") if self == DoubleDouble::Account
        if (is_normal_debit_account && contra) || !(is_normal_debit_account || contra)
          credits_balance(hash) - debits_balance(hash)
        else
          debits_balance(hash) - credits_balance(hash)
        end
      end
  end
end







