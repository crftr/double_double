module DoubleDouble
  # entries are the recording of debits and credits to various accounts.
  # This table can be thought of as a traditional accounting Journal.
  #
  # Posting to a Ledger can be considered to happen automatically, since
  # Accounts have the reverse 'has_many' relationship to either it's credit or
  # debit entries
  #
  # @example
  #   cash = DoubleDouble::Asset.named('Cash')
  #   accounts_receivable = DoubleDouble::Asset.named('Accounts Receivable')
  #
  #   debit_amount = DoubleDouble::DebitAmount.new(account: 'cash', amount: 1000)
  #   credit_amount = DoubleDouble::CreditAmount.new(account: 'accounts_receivable', amount: 1000)
  #
  #   entry = DoubleDouble::Entry.new(description: "Receiving payment on an invoice")
  #   entry.debit_amounts << debit_amount
  #   entry.credit_amounts << credit_amount
  #   entry.save
  #
  # @see http://en.wikipedia.org/wiki/Journal_entry Journal Entry
  #
  class Entry < ActiveRecord::Base
    self.table_name = 'double_double_entries'

    belongs_to :entry_type
    belongs_to :initiator,  polymorphic: true

    has_many :credit_amounts
    has_many :debit_amounts
    has_many :credit_accounts, through: :credit_amounts, source: :account
    has_many :debit_accounts,  through: :debit_amounts,  source: :account

    validates_presence_of :description
    validate :has_credit_amounts?
    validate :has_debit_amounts?
    validate :amounts_cancel?

    scope :by_entry_type, ->(tt) { where(entry_type: tt)}
    scope :by_initiator, ->(i) { where(initiator_id: i.id, initiator_type: i.class.base_class) }

    # Simple API for building a entry and associated debit and credit amounts
    #
    # @example
    #   entry = DoubleDouble::Entry.build(
    #     description: "Sold some widgets",
    #     debits: [
    #       {account: "Accounts Receivable", amount: 50, context: @some_active_record_object}], 
    #     credits: [
    #       {account: "Sales Revenue",       amount: 45},
    #       {account: "Sales Tax Payable",   amount:  5}])
    #
    # @return [DoubleDouble::Entry] A Entry with built credit and debit objects ready for saving
    def self.build args
      args.merge!({credits: args[:debits], debits: args[:credits]}) if args[:reversed]
      t = Entry.new()
      t.description      = args[:description]
      t.entry_type = args[:entry_type] if args.has_key? :entry_type
      t.initiator        = args[:initiator]        if args.has_key? :initiator
      add_amounts_to_entry(args[:debits],  t, true)
      add_amounts_to_entry(args[:credits], t, false)
      t
    end

    def self.create! args
      t = build args
      t.save!
    end

    def entry_type
      self.entry_type_id.nil? ? UnassignedEntryType : EntryType.find(self.entry_type_id)
    end

    private

      # Validation
      
      def has_credit_amounts?
        errors[:base] << "Entry must have at least one credit amount" if self.credit_amounts.blank?
      end

      def has_debit_amounts?
        errors[:base] << "Entry must have at least one debit amount" if self.debit_amounts.blank?
      end

      def amounts_cancel?
        errors[:base] << "The credit and debit amounts are not equal" if difference_of_amounts.cents != 0
      end

      def difference_of_amounts
        credit_amount_total = credit_amounts.inject(Money.new(0)) {|sum, credit_amount| sum + credit_amount.amount}
        debit_amount_total  = debit_amounts.inject(Money.new(0))  {|sum,  debit_amount| sum +  debit_amount.amount}
        credit_amount_total - debit_amount_total
      end

      # Assist entry building

      def self.add_amounts_to_entry amounts, entry, add_to_debits = true
        return if amounts.nil? || amounts.count == 0
        amounts.each do |amt|
          amount_parameters = prepare_amount_parameters amt.merge!({entry: entry})
          new_amount = add_to_debits ? DebitAmount.new : CreditAmount.new
          new_amount.assign_attributes(amount_parameters)
          entry.debit_amounts << new_amount  if add_to_debits
          entry.credit_amounts << new_amount unless add_to_debits
        end
      end

      def self.prepare_amount_parameters args
        account = args[:account].is_a?(Integer) ? Account.numbered(args[:account]) : Account.named(args[:account])
        prepared_params = { account: account, entry: args[:entry], amount: args[:amount]}
        prepared_params.merge!({accountee:  args[:accountee]})  if args.has_key? :accountee
        prepared_params.merge!({context:    args[:context]})    if args.has_key? :context
        prepared_params.merge!({subcontext: args[:subcontext]}) if args.has_key? :subcontext
        prepared_params
      end
  end
end