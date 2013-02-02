module DoubleDouble
  describe DebitAmount do

    before(:each) do
      @cash = DoubleDouble::Asset.create!(name:'Cash', number: 11)
      @loan = DoubleDouble::Liability.create!(name:'Loan', number: 12)
      @dummy_transaction = DoubleDouble::Transaction.new
      @job = DoubleDouble::Expense.create!(name: 'stand-in job', number: 999)
      @po  = DoubleDouble::Expense.create!(name: 'stand-in purchase order', number: 333)
    end

    it "should not be valid without an amount" do
      expect {
        c = DoubleDouble::DebitAmount.new
        c.amount = nil
        c.account = @cash
        c.transaction = @dummy_transaction
        c.save!
      }.to raise_error(ArgumentError)
    end

    it "should not be valid with an amount of 0" do
      c = DoubleDouble::DebitAmount.new
      c.amount = 0
      c.account = @cash
      c.transaction = @dummy_transaction
      c.should_not be_valid
    end

    it "should not be valid without a transaction" do
      c = DoubleDouble::DebitAmount.new
      c.amount = 9
      c.account = @cash
      c.transaction = nil
      c.should_not be_valid
    end

    it "should not be valid without an account" do
      c = DoubleDouble::DebitAmount.new
      c.amount = 9
      c.account = nil
      c.transaction = @dummy_transaction
      c.should_not be_valid
    end
    
    it "should be sensitive to 'context' when calculating balances, if supplied" do
      Transaction.create!(
          description: 'Foobar1',
          debits:  [{account: 'Cash', amount: Money.new(123), context: @job}], 
          credits: [{account: 'Loan', amount: Money.new(123)}])
      Transaction.create!(
          description: 'Foobar2',
          debits:  [{account: 'Cash', amount: Money.new(321), context: @job}], 
          credits: [{account: 'Loan', amount: Money.new(321)}])
      Transaction.create!(
          description: 'Foobar3',
          debits:  [{account: 'Cash', amount: Money.new(275), context: @po}], 
          credits: [{account: 'Loan', amount: Money.new(275)}])
      Transaction.create!(
          description: 'Foobar4',
          debits:  [{account: 'Cash', amount: Money.new(999)}], 
          credits: [{account: 'Loan', amount: Money.new(999)}])
      @cash.debits_balance({context: @job}).should == Money.new(123 + 321)
      @cash.debits_balance({context: @po}).should == Money.new(275)
      @cash.debits_balance.should == Money.new(123 + 321 + 275 + 999)
      Account.trial_balance.should eq(0)
    end
  end
end
