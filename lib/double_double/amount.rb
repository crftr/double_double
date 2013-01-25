module DoubleDouble
  # The Amount class represents debit and credit amounts in the system.
  #
  # @abstract
  #   An amount must be a subclass as either a debit or a credit to be saved to the database. 
  #
  class Amount < ActiveRecord::Base
    self.table_name = 'double_double_amounts'

    attr_accessible :account, :amount, :transaction, :project_id, :approving_user_id, :targeted_user_id
    
    belongs_to :transaction
    belongs_to :account
    belongs_to :project
    belongs_to :approving_user, :class_name => "User"
    belongs_to :targeted_user,  :class_name => "User"
    
    scope :by_project_id,        lambda{|p_id| where(:project_id => p_id)}
    scope :by_approving_user_id, lambda{|au_id| where(:approving_user_id => au_id)}
    scope :by_targeted_user_id,  lambda{|tu_id| where(:targeted_user_id => tu_id)}

    scope :by_transaction_type_number, lambda{|tt_num| where( transaction: {transaction_type: {number: tt_num}})}

    validates_presence_of :type, :amount_cents, :transaction, :account
    
    composed_of :amount,
      :class_name => "Money",
      :mapping => [%w(amount_cents cents), %w(currency currency_as_string)],
      :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) },
      :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }
    
  end
end