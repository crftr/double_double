FactoryGirl.define do
  factory :amount, class: DoubleDouble::Amount do |amount|
  end

  factory :credit_amt, class: DoubleDouble::CreditAmount  do
  end

  factory :debit_amt, class: DoubleDouble::DebitAmount  do
  end
end