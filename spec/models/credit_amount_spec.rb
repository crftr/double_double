module DoubleDouble
  describe CreditAmount do

    it "should not be valid without an amount" do
      expect {
        FactoryGirl.build(:credit_amt, amount: nil, transaction: FactoryGirl.build(:transaction))
      }.to raise_error(ArgumentError)
    end

    it "should not be valid without a transaction" do
      acct = FactoryGirl.create(:asset)
      credit_amount = FactoryGirl.build(:credit_amt, transaction: nil, account: acct, amount: Money.new(20))
      credit_amount.should_not be_valid
    end

    it "should not be valid without an account" do
      t = FactoryGirl.build(:transaction)
      credit_amount = FactoryGirl.build(:credit_amt, account: nil, transaction: t, amount: Money.new(20))
      credit_amount.should_not be_valid
    end
    
    it "should be sensitive to project_id when calculating balances, if supplied" do
      acct_1     = FactoryGirl.create(:asset)
      other_acct = FactoryGirl.create(:not_asset)
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(123), account: acct_1, project_id: 77)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(123), account: other_acct)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(321), account: acct_1, project_id: 77)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(321), account: other_acct)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(275), account: acct_1, project_id: 82)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(275), account: other_acct)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(999), account: acct_1)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(999), account: other_acct)
      t.save
      acct_1.credits_balance({project_id: 77}).should == Money.new(123 + 321)
      acct_1.credits_balance({project_id: 82}).should == Money.new(275)
      acct_1.credits_balance.should                   == Money.new(123 + 321 + 275 + 999)
    end
  end
end
