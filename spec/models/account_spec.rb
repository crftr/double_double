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

    it "should report a trial balance of 0 with correct entries (with a contrived example of entries)" do
      # credit accounts
      FactoryGirl.create(:liability, name: 'liability acct')
      FactoryGirl.create(:equity,    name: 'equity acct')
      FactoryGirl.create(:revenue,   name: 'revenue acct')
      FactoryGirl.create(:asset,     name: 'contra asset acct',   :contra => true)
      FactoryGirl.create(:expense,   name: 'contra expense acct', :contra => true)
      # debit accounts
      FactoryGirl.create(:asset,     name: 'asset acct')
      FactoryGirl.create(:expense,   name: 'expense acct')
      FactoryGirl.create(:liability, name: 'contra liability acct', :contra => true)
      FactoryGirl.create(:equity,    name: 'contra equity acct',    :contra => true)
      FactoryGirl.create(:revenue,   name: 'contra revenue acct',   :contra => true)
      Entry.create!(
        description: 'spec entry 01',
        debits:  [{account: 'liability acct', amount: 100_000}],
        credits: [{account: 'asset acct',     amount: 100_000}])
      Entry.create!(
        description: 'spec entry 02',
        debits:  [{account: 'equity acct',  amount: 1_000}],
        credits: [{account: 'expense acct', amount: 1_000}])
      Entry.create!(
        description: 'spec entry 03',
        debits:  [{account: 'revenue acct',          amount: 40_404}],
        credits: [{account: 'contra liability acct', amount: 40_404}])
      Entry.create!(
        description: 'spec entry 04',
        debits:  [{account: 'contra asset acct',  amount: 2}], 
        credits: [{account: 'contra equity acct', amount: 2}])
      Entry.create!(
        description: 'spec entry 05',
        debits:  [{account: 'contra expense acct', amount: 333}], 
        credits: [{account: 'contra revenue acct', amount: 333}])
      Account.trial_balance.should eq(0)
    end

    it "should accept an account number when creating entries" do
      FactoryGirl.create(:liability, name: 'liability acct', number: 800)
      FactoryGirl.create(:asset,     name: 'asset acct', number: 600)
      Entry.create!(
          description: 'spec entry 01',
          debits:  [{account: 800, amount: 100_000}],
          credits: [{account: 600,     amount: 100_000}])
      Account.trial_balance.should eq(0)
    end
  end
end
