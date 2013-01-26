# The shared behaviors that all account types should exhibit.
#
# For clarification, the following will return the class object represented in account_type
# 
# @example
#   account_type = :asset
#   DoubleDouble.const_get(account_type.to_s.capitalize)  # returns the DoubleDouble::Asset class object

shared_examples "all account types" do
  describe "<<" do

    before(:all) do
      @capitalized_account_type = account_type.to_s.capitalize
    end

    it "should allow creating an account" do
      -> { account = FactoryGirl.create(account_type) }.should change(DoubleDouble::Account, :count).by(1)
    end

    it "should not report a trial balance" do
      -> { DoubleDouble.const_get(@capitalized_account_type).trial_balance }.should raise_error(NoMethodError)
    end

    it "should not be valid without a name" do
      account = FactoryGirl.build(account_type, :name => nil)
      account.should_not be_valid
    end

    it "should respond_to credit_transactions" do
      account = FactoryGirl.build(account_type)
      account.should respond_to(:credit_transactions)
    end

    it "should respond_to debit_transactions" do
      account = FactoryGirl.build(account_type)
      account.should respond_to(:debit_transactions)
    end

    it "a contra account should be capable of balancing against a non-contra account" do
      account        = FactoryGirl.create(account_type)
      contra_account = FactoryGirl.create(account_type, :contra => true)
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: 50, account: account)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: 25, account: account)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: 75, account: contra_account)
      t.save
      DoubleDouble.const_get(@capitalized_account_type).balance.should == 0
    end
  end
end
