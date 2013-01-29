module DoubleDouble
  describe CreditAmount do

    before(:each) do
      @cash = DoubleDouble::Asset.create!(name:'Cash', number: 11)
      @loan = DoubleDouble::Liability.create!(name:'Loan', number: 12)
      @dummy_transaction = DoubleDouble::Transaction.new
      @job = DoubleDouble::Expense.create!(name: 'stand-in job', number: 999)
      @po  = DoubleDouble::Expense.create!(name: 'stand-in purchase order', number: 333)
    end

    it "should not be valid without an amount" do
      expect {
        c = DoubleDouble::CreditAmount.new
        c.amount = nil
        c.account = @cash
        c.transaction = @dummy_transaction
        c.save!
      }.to raise_error(ArgumentError)
    end

    it "should not be valid with an amount of 0" do
      c = DoubleDouble::CreditAmount.new
      c.amount = 0
      c.account = @cash
      c.transaction = @dummy_transaction
      c.should_not be_valid
    end

    it "should not be valid without a transaction" do
      c = DoubleDouble::CreditAmount.new
      c.amount = 9
      c.account = @cash
      c.transaction = nil
      c.should_not be_valid
    end

    it "should not be valid without an account" do
      c = DoubleDouble::CreditAmount.new
      c.amount = 9
      c.account = nil
      c.transaction = @dummy_transaction
      c.should_not be_valid
    end
    
    it "should be sensitive to 'context' when calculating balances, if supplied" do
      Transaction.create!(
          description: 'Foobar1',
          debits:  [{account: 'Cash', amount: Money.new(123)}], 
          credits: [{account: 'Loan', amount: Money.new(123), context: @job}])
      Transaction.create!(
          description: 'Foobar2',
          debits:  [{account: 'Cash', amount: Money.new(321)}], 
          credits: [{account: 'Loan', amount: Money.new(321), context: @job}])
      Transaction.create!(
          description: 'Foobar3',
          debits:  [{account: 'Cash', amount: Money.new(275)}], 
          credits: [{account: 'Loan', amount: Money.new(275), context: @po}])
      Transaction.create!(
          description: 'Foobar4',
          debits:  [{account: 'Cash', amount: Money.new(999)}], 
          credits: [{account: 'Loan', amount: Money.new(999)}])
      @loan.credits_balance({context: @job}).should == Money.new(123 + 321)
      @loan.credits_balance({context: @po}).should == Money.new(275)
      @loan.credits_balance.should == Money.new(123 + 321 + 275 + 999)
    end
  end
end
