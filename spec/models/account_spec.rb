module DoubleDouble
  describe Account do

    it "should not allow creating an account without a subtype" do
      account = DoubleDouble::Account.new(name: 'Cash', number: 10)
      account.should_not be_valid
    end

    it "should be unique per name" do
      DoubleDouble::Asset.new(name: 'Petty Cash', number: 10).save
      account = DoubleDouble::Liability.new(name: 'Petty Cash', number: 11)
      account.should_not be_valid
      account.errors[:name].should == ["has already been taken"]
    end
    
    it "should be unique per number" do
      DoubleDouble::Asset.new(name: 'Cash', number: 22).save
      account = DoubleDouble::Liability.new(name: 'Loan', number: 22)
      account.should_not be_valid
      account.errors[:number].should == ["has already been taken"]
    end

    it "should not have a balance method" do
      -> {Account.balance}.should raise_error(NoMethodError)
    end

    it "should have a trial balance" do
      Account.should respond_to(:trial_balance)
      Account.trial_balance.should be_kind_of(Money)
    end

    it "should report a trial balance of 0 with correct transactions (with a contrived example of transactions)" do
      # credit accounts
      liability      = FactoryGirl.create(:liability)
      equity         = FactoryGirl.create(:equity)
      revenue        = FactoryGirl.create(:revenue)
      contra_asset   = FactoryGirl.create(:asset, :contra => true)
      contra_expense = FactoryGirl.create(:expense, :contra => true)
      # debit accounts
      asset            = FactoryGirl.create(:asset)
      expense          = FactoryGirl.create(:expense)
      contra_liability = FactoryGirl.create(:liability, :contra => true)
      contra_equity    = FactoryGirl.create(:equity, :contra => true)
      contra_revenue   = FactoryGirl.create(:revenue, :contra => true)

      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: 100_000, account: liability)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: 100_000, account: asset)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: 1_000, account: equity)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: 1_000, account: expense)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: 40_404, account: revenue)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: 40_404, account: contra_liability)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: 2, account: contra_asset)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: 2, account: contra_equity)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: 333, account: contra_expense)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: 333, account: contra_revenue)
      t.save

      Account.trial_balance.should == 0
    end
  end
end
