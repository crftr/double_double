module DoubleDouble
  describe CreditAmount do

    before(:each) do
      @cash = DoubleDouble::Asset.create!(name:'Cash', number: 11)
      @loan = DoubleDouble::Liability.create!(name:'Loan', number: 12)
      @dummy_transaction = DoubleDouble::Transaction.new
      @job = DoubleDouble::Expense.create!(name: 'stand-in job', number: 999)
      @po  = DoubleDouble::Expense.create!(name: 'stand-in purchase order', number: 333)
      @item_foo = DoubleDouble::Expense.create!(name: 'stand-in item_foo', number: 1000)
      @item_bar = DoubleDouble::Expense.create!(name: 'stand-in item_bar', number: 1001)
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
          debits:  [{account: 'Cash', amount: 123}], 
          credits: [{account: 'Loan', amount: 123, context: @job}])
      Transaction.create!(
          description: 'Foobar2',
          debits:  [{account: 'Cash', amount: 321}], 
          credits: [{account: 'Loan', amount: 321, context: @job}])
      Transaction.create!(
          description: 'Foobar3',
          debits:  [{account: 'Cash', amount: 275}], 
          credits: [{account: 'Loan', amount: 275, context: @po}])
      Transaction.create!(
          description: 'Foobar4',
          debits:  [{account: 'Cash', amount: 999}], 
          credits: [{account: 'Loan', amount: 999}])
      @loan.credits_balance({context: @job}).should == 123 + 321
      @loan.credits_balance({context: @po}).should == 275
      @loan.credits_balance.should == 123 + 321 + 275 + 999
      Transaction.create!(
          description: 'Foobar5',
          debits:  [{account: 'Cash', amount: 9_999}], 
          credits: [{account: 'Loan', amount: 9_999, context: @job, subcontext: @item_foo}])
      Transaction.create!(
          description: 'Foobar5',
          debits:  [{account: 'Cash', amount: 123}], 
          credits: [{account: 'Loan', amount: 123, context: @po, subcontext: @item_foo}])
      Transaction.create!(
          description: 'Foobar6',
          debits:  [{account: 'Cash', amount: 222}], 
          credits: [{account: 'Loan', amount: 222, context: @po, subcontext: @item_foo}])
      Transaction.create!(
          description: 'Foobar7',
          debits:  [{account: 'Cash', amount: 1}], 
          credits: [{account: 'Loan', amount: 1, context: @po, subcontext: @item_bar}])
      @loan.credits_balance({context: @po, subcontext: @item_foo}).should == 123 + 222
      @loan.credits_balance({context: @po, subcontext: @item_bar}).should == 1

      Account.trial_balance.should eq(0)
    end
  end
end
