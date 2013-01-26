FactoryGirl.define do
  factory :transaction, :class => DoubleDouble::Transaction do
    description { FactoryGirl.generate(:transaction_type_description) }
  end

  sequence :transaction_description do |n|
    "transaction description #{n}"
  end
end