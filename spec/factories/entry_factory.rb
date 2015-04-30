FactoryGirl.define do
  factory :entry, class: DoubleDouble::Entry do
    description { FactoryGirl.generate(:entry_type_description) }
  end

  sequence :entry_description do |n|
    "entry description #{n}"
  end
end