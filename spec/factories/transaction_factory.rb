FactoryGirl.define do
  factory :transaction, :class => DoubleDouble::Transaction do
    description { FactoryGirl.generate(:transaction_type_description) }

    factory :transaction_with_credit_and_debit_amounts do
      credit_amount_entry
      debit_amount_entry
    end

    factory :transaction_with_credit_and_debit_amounts_and_type do
      transaction_with_credit_and_debit
      transaction_type_added
    end

    # Traits

    trait :credit_amount_entry do
      after(:build) {|t| t.credit_amounts << FactoryGirl.build(:credit_amount, transaction: t) }
    end

    trait :debit_amount_entry do
      after(:build) {|t| t.debit_amounts  << FactoryGirl.build(:debit_amount,  transaction: t) }
    end

    trait :transaction_type_added do
      transaction_type { FactoryGirl.generate(:transaction_type) }
    end
  end

  sequence :transaction_description do |n|
    "transaction description #{n}"
  end
end