module DoubleDouble
  # Transactions are the recording of debits and credits to various accounts.
  # This table can be thought of as a traditional accounting Journal.
  #
  # Posting to a Ledger can be considered to happen automatically, since
  # Accounts have the reverse 'has_many' relationship to either it's credit or
  # debit transactions
  #
  # @example
  #   cash = DoubleDouble::Asset.find_by_name('Cash')
  #   accounts_receivable = DoubleDouble::Asset.find_by_name('Accounts Receivable')
  #
  #   debit_amount = DoubleDouble::DebitAmount.new(:account => cash, :amount => 1000)
  #   credit_amount = DoubleDouble::CreditAmount.new(:account => accounts_receivable, :amount => 1000)
  #
  #   transaction = DoubleDouble::Transaction.new(:description => "Receiving payment on an invoice")
  #   transaction.debit_amounts << debit_amount
  #   transaction.credit_amounts << credit_amount
  #   transaction.save
  #
  # @see http://en.wikipedia.org/wiki/Journal_entry Journal Entry
  #
  class Transaction < ActiveRecord::Base
    self.table_name = 'double_double_transactions'

    attr_accessible :description, :commercial_document

    belongs_to :transaction_type
    belongs_to :commercial_document, :polymorphic => true

    has_many :credit_amounts
    has_many :debit_amounts
    has_many :credit_accounts, :through => :credit_amounts, :source => :account
    has_many :debit_accounts, :through => :debit_amounts, :source => :account

    validates_presence_of :description
    validate :has_credit_amounts?
    validate :has_debit_amounts?
    validate :amounts_cancel?

    scope :by_transaction_type_number, lambda{|tt_num| where(transaction_type: {number: tt_num})}

    # Simple API for building a transaction and associated debit and credit amounts
    #
    # @example
    #   transaction = DoubleDouble::Transaction.build(
    #     description: "Sold some widgets",
    #     debits: [
    #       {account: "Accounts Receivable", amount: 50}], 
    #     credits: [
    #       {account: "Sales Revenue", amount: 45},
    #       {account: "Sales Tax Payable", amount: 5}])
    #
    # @return [DoubleDouble::Transaction] A Transaction with built credit and debit objects ready for saving
    def self.build(hash)
      transaction = Transaction.new(description: hash[:description], commercial_document: hash[:commercial_document])
      hash[:debits].each do |debit|
        a = Account.find_by_name(debit[:account])
        transaction.debit_amounts << DebitAmount.new(account: a, amount: debit[:amount], transaction: transaction, project_id: debit[:project_id], approving_user_id: debit[:approving_user_id], targeted_user_id: debit[:targeted_user_id])
      end
      hash[:credits].each do |credit|
        a = Account.find_by_name(credit[:account])
        transaction.credit_amounts << CreditAmount.new(account: a, amount: credit[:amount], transaction: transaction, project_id: credit[:project_id], approving_user_id: credit[:approving_user_id], targeted_user_id: credit[:targeted_user_id])
      end
      transaction.transaction_type = hash[:transaction_type] if hash.has_key?(:transaction_type)
      transaction
    end

    private
      def has_credit_amounts?
        errors[:base] << "Transaction must have at least one credit amount" if self.credit_amounts.blank?
      end

      def has_debit_amounts?
        errors[:base] << "Transaction must have at least one debit amount" if self.debit_amounts.blank?
      end

      def amounts_cancel?
        errors[:base] << "The credit and debit amounts are not equal" if difference_of_amounts != 0
      end

      def difference_of_amounts
        credit_amount_total = credit_amounts.inject(Money.new(0)) {|sum, credit_amount| sum + credit_amount.amount}
        debit_amount_total  = debit_amounts.inject(Money.new(0))  {|sum, debit_amount|  sum + debit_amount.amount}
        credit_amount_total - debit_amount_total
      end
  end
end