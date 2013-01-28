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

    attr_accessible :description

    belongs_to :transaction_type

    has_many :credit_amounts
    has_many :debit_amounts
    has_many :credit_accounts, through: :credit_amounts, source: :account
    has_many :debit_accounts,  through: :debit_amounts,  source: :account

    validates_presence_of :description
    validate :has_credit_amounts?
    validate :has_debit_amounts?
    validate :amounts_cancel?

    scope :by_transaction_type_number, ->(tt_num) { where(transaction_type: {number: tt_num})}

    # Simple API for building a transaction and associated debit and credit amounts
    #
    # @example
    #   transaction = DoubleDouble::Transaction.build(
    #     description: "Sold some widgets",
    #     debits: [
    #       {account: "Accounts Receivable", amount: 50, context_id: 20, context_type: 'Job'}], 
    #     credits: [
    #       {account: "Sales Revenue",       amount: 45},
    #       {account: "Sales Tax Payable",   amount:  5}])
    #
    # @return [DoubleDouble::Transaction] A Transaction with built credit and debit objects ready for saving
    def self.build args
      t = Transaction.new()
      t.description      = args[:description]
      t.transaction_type = args[:transaction_type] if args.has_key?(:transaction_type)
      add_amounts_to_transaction(args[:debits],  t, true)
      add_amounts_to_transaction(args[:credits], t, false)
      t
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

      def self.add_amounts_to_transaction amounts, transaction, add_to_debit_side = true
        amounts.each do |amt|
          amount_parameters = prepare_amount_parameters amt.merge!({transaction: transaction})
          new_amount = add_to_debit_side ? DebitAmount.new : CreditAmount.new
          new_amount.assign_attributes(amount_parameters, as: :transation_builder)
          transaction.debit_amounts << new_amount  if add_to_debit_side
          transaction.credit_amounts << new_amount unless add_to_debit_side
        end
      end

      def self.prepare_amount_parameters args
        prepared_params = { account: Account.find_by_name(args[:account]), transaction: args[:transaction], amount: args[:amount]}
        polymorphic_sets = [[:context_id, :context_type], [:initiator_id, :initiator_type], [:accountee_id, :accountee_type]]
        polymorphic_sets.each do |polymorphic_set|
          prepared_params.merge!(hash_parameters_if_they_all_exist(polymorphic_set, args))
        end
        prepared_params
      end

      # Verify that polymorphic associations are only written if both ID and TYPE are present.
      def self.hash_parameters_if_they_all_exist keys_to_check_for, hash_to_check_against
        return_hash = {}
        if (hash_to_check_against.keys & keys_to_check_for).count == keys_to_check_for.count
          keys_to_check_for.each do |param|
            return_hash[param] = hash_to_check_against[param]
          end
        end
        return_hash
      end
  end
end