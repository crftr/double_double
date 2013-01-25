FactoryGirl.define do
  factory :transaction_type, :class => DoubleDouble::TransactionType do |type|
    type.description  { FactoryGirl.generate(:transaction_type_description) }
    type.number       { FactoryGirl.generate(:transaction_type_number)      }
  end

  sequence :transaction_type_description do |n|
    "transaction type description #{n}"
  end

  sequence :transaction_type_number do |n|
    9000 + n
  end
end