module DoubleDouble
  # Transactions are the recording of debits and credits to various accounts.
  # This table can be thought of as a traditional accounting Journal.
  #
  # Posting to a Ledger can be considered to happen automatically, since
  # Accounts have the reverse 'has_many' relationship to either it's credit or
  # debit transactions
  #
  # @example
  #   cash = DoubleDouble::Asset.named('Cash')
  #   accounts_receivable = DoubleDouble::Asset.named('Accounts Receivable')
  #
  #   debit_amount = DoubleDouble::DebitAmount.new(account: 'cash', amount: 1000)
  #   credit_amount = DoubleDouble::CreditAmount.new(account: 'accounts_receivable', amount: 1000)
  #
  #   transaction = DoubleDouble::Transaction.new(description: "Receiving payment on an invoice")
  #   transaction.debit_amounts << debit_amount
  #   transaction.credit_amounts << credit_amount
  #   transaction.save
  #
  # @see http://en.wikipedia.org/wiki/Journal_entry Journal Entry
  #
  class Transaction < ActiveRecord::Base
    self.table_name = 'double_double_transactions'

    attr_accessible :description, :initiator

    belongs_to :transaction_type
    belongs_to :initiator,  polymorphic: true

    has_many :credit_amounts
    has_many :debit_amounts
    has_many :credit_accounts, through: :credit_amounts, source: :account
    has_many :debit_accounts,  through: :debit_amounts,  source: :account

    validates_presence_of :description
    validate :has_credit_amounts?
    validate :has_debit_amounts?
    validate :amounts_cancel?

    scope :by_transaction_type, ->(tt) { where(transaction_type: tt)}
    scope :by_initiator, ->(i) { where(initiator_id: i.id, initiator_type: i.class.base_class) }

    # Simple API for building a transaction and associated debit and credit amounts
    #
    # @example
    #   transaction = DoubleDouble::Transaction.build(
    #     description: "Sold some widgets",
    #     debits: [
    #       {account: "Accounts Receivable", amount: 50, context: @some_active_record_object}], 
    #     credits: [
    #       {account: "Sales Revenue",       amount: 45},
    #       {account: "Sales Tax Payable",   amount:  5}])
    #
    # @return [DoubleDouble::Transaction] A Transaction with built credit and debit objects ready for saving
    def self.build args
      t = Transaction.new()
      t.description      = args[:description]
      t.transaction_type = args[:transaction_type] if args.has_key? :transaction_type
      t.initiator        = args[:initiator]        if args.has_key? :initiator
      add_amounts_to_transaction(args[:debits],  t, true) 
      add_amounts_to_transaction(args[:credits], t, false)
      t
    end

    def self.create! args
      t = build args
      t.save!
    end

    def transaction_type
      self.transaction_type_id.nil? ? UnassignedTransactionType : TransactionType.find(self.transaction_type_id)
    end

    private

      # Validation
      
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
        debit_amount_total  = debit_amounts.inject(Money.new(0))  {|sum,  debit_amount| sum +  debit_amount.amount}
        credit_amount_total - debit_amount_total
      end

      # Assist transaction building

      def self.add_amounts_to_transaction amounts, transaction, add_to_debits = true
        return if amounts.nil? || amounts.count == 0
        amounts.each do |amt|
          amount_parameters = prepare_amount_parameters amt.merge!({transaction: transaction})
          new_amount = add_to_debits ? DebitAmount.new : CreditAmount.new
          new_amount.assign_attributes(amount_parameters, as: :transation_builder)
          transaction.debit_amounts << new_amount  if add_to_debits
          transaction.credit_amounts << new_amount unless add_to_debits
        end
      end

      def self.prepare_amount_parameters args
        prepared_params = { account: Account.named(args[:account]), transaction: args[:transaction], amount: args[:amount]}
        prepared_params.merge!({accountee: args[:accountee]}) if args.has_key? :accountee
        prepared_params.merge!({context:   args[:context]})   if args.has_key? :context
        prepared_params
      end
  end
end