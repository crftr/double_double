# The shared behaviors that all account types should exhibit.
#
# For clarification, the following will return the class object represented in account_type
# 
# @example
#   account_type = :asset
#   DoubleDouble.const_get(account_type.to_s.capitalize)  # returns the DoubleDouble::Asset class object

shared_examples "all account types" do
  describe "<<" do

    before(:each) do
      @capitalized_account_type = account_type.to_s.capitalize
    end

    it "should allow creating an account" do
      -> { DoubleDouble.const_get(@capitalized_account_type).create! name: 'test acct', number: 2
      }.should change(DoubleDouble::Account, :count).by(1)
    end

    it "should not report a trial balance" do
      -> { DoubleDouble.const_get(@capitalized_account_type).trial_balance }.should raise_error(NoMethodError)
    end

    it "should not be valid without a name" do
      account = DoubleDouble.const_get(@capitalized_account_type).new(number: 998)
      account.should_not be_valid
      account = DoubleDouble.const_get(@capitalized_account_type).new(name: nil, number: 997)
      account.should_not be_valid
      account = DoubleDouble.const_get(@capitalized_account_type).new(name: '', number: 996)
      account.should_not be_valid
    end

    it "should respond_to credit_entries" do
      account = DoubleDouble.const_get(@capitalized_account_type).create!(name: 'acct', number: 999)
      account.should respond_to(:credit_entries)
    end

    it "should respond_to debit_entries" do
      account = DoubleDouble.const_get(@capitalized_account_type).create!(name: 'acct', number: 999)
      account.should respond_to(:debit_entries)
    end

    it "a contra account should be capable of balancing against a non-contra account" do
      DoubleDouble.const_get(@capitalized_account_type).create!(name: 'acct1', number: 1)
      DoubleDouble.const_get(@capitalized_account_type).create!(name: 'acct2', number: 2, contra: true)
      DoubleDouble::Entry.create!(
        description: 
          'testing contra balancing',
        debits:[
          {account: 'acct1', amount: '$250'},
          {account: 'acct1', amount: '$550'}],
        credits:[
          {account: 'acct2', amount: '$800'}])
      DoubleDouble.const_get(@capitalized_account_type).balance.should == 0
    end
  end
end
