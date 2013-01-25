module DoubleDouble
  describe CreditAmount do

    it "should not be valid without an amount" do
      expect{FactoryGirl.build(:credit_amount, :amount => nil)}.to raise_error(ArgumentError)
    end

    it "should not be valid without a transaction" do
      credit_amount = FactoryGirl.build(:credit_amount, :transaction => nil)
      credit_amount.should_not be_valid
    end

    it "should not be valid without an account" do
      credit_amount = FactoryGirl.build(:credit_amount, :account => nil)
      credit_amount.should_not be_valid
    end
    
    it "should be sensitive to project_id when calculating balances, if supplied" do
      @acct_1 = FactoryGirl.create(:asset)
      FactoryGirl.create(:credit_amount, account: @acct_1, amount: Money.new(123),  project_id: 77)
      FactoryGirl.create(:credit_amount, account: @acct_1, amount: Money.new(321),  project_id: 77)
      FactoryGirl.create(:credit_amount, account: @acct_1, amount: Money.new(275),  project_id: 82)
      FactoryGirl.create(:credit_amount, account: @acct_1, amount: Money.new(999))
      @acct_1.credits_balance({project_id: 77}).should == Money.new(123 + 321)
      @acct_1.credits_balance({project_id: 82}).should == Money.new(275)
      @acct_1.credits_balance.should == Money.new(123 + 321 + 275 + 999)
    end

  end
end
