module DoubleDouble
  describe DebitAmount do

    it "should not be valid without an amount" do
      expect{FactoryGirl.build(:debit_amount, :amount => nil)}.to raise_error(ArgumentError)
    end

    it "should not be valid without a transaction" do
      debit_amount = FactoryGirl.build(:debit_amount, :transaction => nil)
      debit_amount.should_not be_valid
    end

    it "should not be valid without an account" do
      debit_amount = FactoryGirl.build(:debit_amount, :account => nil)
      debit_amount.should_not be_valid
    end
    
    it "should be sensitive to project_id when calculating balances, if supplied" do
      @acct_1 = FactoryGirl.create(:asset)
      FactoryGirl.create(:debit_amount, account: @acct_1, amount: Money.new(123),  project_id: 77)
      FactoryGirl.create(:debit_amount, account: @acct_1, amount: Money.new(321),  project_id: 77)
      FactoryGirl.create(:debit_amount, account: @acct_1, amount: Money.new(275),  project_id: 82)
      FactoryGirl.create(:debit_amount, account: @acct_1, amount: Money.new(999))
      @acct_1.debits_balance({project_id: 77}).should == Money.new(123 + 321)
      @acct_1.debits_balance({project_id: 82}).should == Money.new(275)
      @acct_1.debits_balance.should == Money.new(123 + 321 + 275 + 999)
    end

  end
end