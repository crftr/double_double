FactoryGirl.define do
  factory :amount, :class => DoubleDouble::Amount do |amount|
    amount.amount {FactoryGirl.generate(:amount_money)}

    amount.association :transaction, :factory => :transaction_with_credit_and_debit_amounts
    amount.association :account, :factory => :asset
    
    factory :credit_amount, :class => DoubleDouble::CreditAmount do |credit_amount|
      credit_amount.association :account, :factory => :revenue
    end

    factory :debit_amount, :class => DoubleDouble::DebitAmount do |debit_amount|
      debit_amount.association :account, :factory => :asset
    end

    # Testing

    ignore do
      # account_class_factory :asset
    end
    
  end

  sequence :amount_money do |n|
    Money.new(473)
  end

  factory :credit_amt, :class => DoubleDouble::CreditAmount  do
    # amount { FactoryGirl.generate(:amount_money) }
  end

  factory :debit_amt, :class => DoubleDouble::DebitAmount  do
    # amount { FactoryGirl.generate(:amount_money) }
  end

  factory :trans, :class => DoubleDouble::Transaction do |t|
    t.description { FactoryGirl.generate(:transaction_type_description) }

    ignore do
      cr { Hash.new }
      dr { Hash.new }
    end

    after(:build) do |t|
      t.credit_amounts << FactoryGirl.build(:credit_amt, transaction: t, account: cr[:account], amount: cr[:amount])
      t.debit_amounts  << FactoryGirl.build(:debit_amt,  transaction: t, account: dr[:account], amount: dr[:amount])
    end
  end

end
