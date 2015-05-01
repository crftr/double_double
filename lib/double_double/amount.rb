module DoubleDouble
  # The Amount class represents debit and credit amounts in the system.
  #
  # @abstract
  #   An amount must be a subclass as either a debit or a credit to be saved to the database. 
  #
  class Amount < ActiveRecord::Base
    self.table_name = 'double_double_amounts'

    belongs_to :entry
    belongs_to :account
    belongs_to :accountee,  polymorphic: true
    belongs_to :context,    polymorphic: true
    belongs_to :subcontext, polymorphic: true
    
    scope :by_accountee,   ->(a) { where(accountee_id:  a.id, accountee_type:  a.class.base_class) }
    scope :by_context,     ->(c) { where(context_id:    c.id, context_type:    c.class.base_class) }
    scope :by_subcontext,  ->(s) { where(subcontext_id: s.id, subcontext_type: s.class.base_class) }
    scope :by_entry_type,  ->(e) { joins(:entry).where(double_double_entries: {entry_type_id: e}) }

    validates_presence_of :type, :entry, :account
    validates :amount_cents, numericality: { greater_than: 0 }

    composed_of :amount,
      class_name: "Money",
      mapping: [%w(amount_cents cents), %w(currency currency_as_string)],
      constructor: Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) }

    # [dane] Workaround to deal with the fact that composed of will never use the converter for a nil value. Otherwise,
    # we could have simply passed a converter to composed_of. See ActiveRecord::Aggregations#writer_method
    #
    def amount=(part)
      unless part.is_a?(Money)
        part = Monetize.parse(part)
        raise(ArgumentError, "Can't convert #{value.class} to Money") unless part
      end
      mapping = [%w(amount_cents cents), %w(currency currency_as_string)]
      mapping.each { |pair| self[pair.first] = part.send(pair.last) }
      @aggregation_cache[:amount] = part.freeze
    end
  end
end