module DoubleDouble
  # The Amount class represents debit and credit amounts in the system.
  #
  # @abstract
  #   An amount must be a subclass as either a debit or a credit to be saved to the database. 
  #
  class Amount < ActiveRecord::Base
    self.table_name = 'double_double_amounts'

    attr_accessible :account, :amount, :transaction, :context_id, :context_type, 
                    :initiator_id, :initiator_type, :accountee_id, :accountee_type, as: :transation_builder
    
    belongs_to :transaction
    belongs_to :account
    belongs_to :context,    polymorphic: true
    belongs_to :initiator,  polymorphic: true
    belongs_to :accountee,  polymorphic: true
    
    scope :by_context,   ->(c_id, c_base_class) { where(context_id:   c_id, context_type:   c_base_class) }
    scope :by_initiator, ->(i_id, i_base_class) { where(initiator_id: i_id, initiator_type: i_base_class) }
    scope :by_accountee, ->(a_id, a_base_class) { where(accountee_id: a_id, accountee_type: a_base_class) }

    # scope :by_transaction_type_number, -> {|tt_num| where( transaction: {transaction_type: {number: tt_num}})}

    validates_presence_of :type, :transaction, :account
    validates :amount_cents, numericality: {greater_than: 0}
    
    composed_of :amount,
      class_name: "Money",
      mapping: [%w(amount_cents cents), %w(currency currency_as_string)],
      constructor: Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) },
      converter: Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }
  end
end