FactoryGirl.define do
  factory :account, :class => DoubleDouble::Account do |account|
    account.name   { FactoryGirl.generate(:account_name)  }
    account.number { FactoryGirl.generate(:account_number)}
    account.contra false

    factory :asset,     :class => DoubleDouble::Asset
    factory :equity,    :class => DoubleDouble::Equity
    factory :expense,   :class => DoubleDouble::Expense
    factory :liability, :class => DoubleDouble::Liability
    factory :revenue,   :class => DoubleDouble::Revenue

    factory :not_asset,     :class => DoubleDouble::Liability
    factory :not_equity,    :class => DoubleDouble::Asset
    factory :not_expense,   :class => DoubleDouble::Liability
    factory :not_liability, :class => DoubleDouble::Asset
    factory :not_revenue,   :class => DoubleDouble::Asset
  end
  
  sequence :account_name do |n|
    "account name #{n}"
  end

  sequence :account_number do |n|
    8000 + n
  end
end
