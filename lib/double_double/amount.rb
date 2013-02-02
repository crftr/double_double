module DoubleDouble
  # The Amount class represents debit and credit amounts in the system.
  #
  # @abstract
  #   An amount must be a subclass as either a debit or a credit to be saved to the database. 
  #
  class Amount < ActiveRecord::Base
    self.table_name = 'double_double_amounts'

    attr_accessible :account, :amount, :transaction, :context, :initiator, :accountee, as: :transation_builder
    
    belongs_to :transaction
    belongs_to :account
    belongs_to :accountee,  polymorphic: true
    belongs_to :context,    polymorphic: true
    
    scope :by_accountee, ->(a) { where(accountee_id: a.id, accountee_type: a.class.base_class) }
    scope :by_context,   ->(c) { where(context_id:   c.id, context_type:   c.class.base_class) }

    validates_presence_of :type, :transaction, :account
    validates :amount_cents, numericality: {greater_than: 0}
    
    composed_of :amount,
      class_name: "Money",
      mapping: [%w(amount_cents cents), %w(currency currency_as_string)],
      constructor: Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) },
      converter: Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }
  end
end