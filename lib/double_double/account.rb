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
  #   DoubleDouble::Equity.create(:name => "Drawing", contra => true)
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
    has_many :credit_transactions, :through => :credit_amounts, :source => :transaction
    has_many :debit_transactions, :through => :debit_amounts, :source => :transaction

    validates_presence_of :type, :name, :number
    validates_uniqueness_of :name, :number

    def side_balance(is_debit, hash)
      a = is_debit ? DoubleDouble::DebitAmount.scoped : DoubleDouble::CreditAmount.scoped
      a = a.where(account_id: self.id)
      a = a.by_project_id( hash[:project_id] )               if hash.has_key?(:project_id)
      a = a.by_approving_user_id( hash[:approving_user_id] ) if hash.has_key?(:approving_user_id)
      a = a.by_targeted_user_id( hash[:targeted_user_id] )   if hash.has_key?(:targeted_user_id)
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
      raise(NoMethodError, "undefined method 'trial_balance'") unless self.new.class == DoubleDouble::Account
      Asset.balance - (Liability.balance + Equity.balance + Revenue.balance - Expense.balance)
    end
    
    def self.balance
      raise(NoMethodError, "undefined method 'balance'") if self.new.class == DoubleDouble::Account
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
    
  end
end
