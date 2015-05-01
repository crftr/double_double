module DoubleDouble
  describe Account do
    it "should not allow creating an account without a subtype" do
      account = DoubleDouble::Account.new(name: 'Cash', number: 10)
      expect(account).to_not be_valid
    end

    it "should be unique per name" do
      DoubleDouble::Asset.new(name: 'Petty Cash', number: 10).save
      account = DoubleDouble::Liability.new(name: 'Petty Cash', number: 11)
      expect(account).to_not be_valid
      expect(account.errors[:name]).to eq(["has already been taken"])
    end
    
    it "should be unique per number" do
      DoubleDouble::Asset.new(name: 'Cash', number: 22).save
      account = DoubleDouble::Liability.new(name: 'Loan', number: 22)
      expect(account).to_not be_valid
      expect(account.errors[:number]).to eq(["has already been taken"])
    end

    it "should not have a balance method" do
      expect {Account.balance}.to raise_error(NoMethodError)
    end

    it "should have a trial balance" do
      expect(Account).to respond_to(:trial_balance)
      expect(Account.trial_balance).to be_kind_of(Money)
    end

    it "should report a trial balance of 0 after an entry is recorded" do
      FactoryGirl.create(:liability, name: 'liability acct')
      FactoryGirl.create(:asset,     name: 'asset acct')
      expect {
        Entry.create!(
          description: 'Entry for trial balance test',
          debits:  [{account: 'liability acct', amount: 123_456}],
          credits: [{account: 'asset acct',     amount: 123_456}])
      }.to change(Account, :trial_balance).by(0)
    end

    it "should return the specified account when calling .named" do
      acct_name = 'named'
      named_account = FactoryGirl.create(:liability, name: acct_name)
      expect(Account.named(acct_name)).to eq(named_account)
    end

    it "should return the specified account when calling .numbered" do
      acct_number = 800
      numbered_account = FactoryGirl.create(:liability, name: 'numbered', number: acct_number)
      expect(Account.numbered(acct_number)).to eq(numbered_account)
    end
  end
end