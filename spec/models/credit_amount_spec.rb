module DoubleDouble
  describe CreditAmount do
    before(:each) do
      @cash = DoubleDouble::Asset.create!(name:'Cash', number: 11)
      @loan = DoubleDouble::Liability.create!(name:'Loan', number: 12)
      @dummy_entry = DoubleDouble::Entry.new
      @job = DoubleDouble::Expense.create!(name: 'stand-in job', number: 999)
      @po  = DoubleDouble::Expense.create!(name: 'stand-in purchase order', number: 333)
      @item_foo = DoubleDouble::Expense.create!(name: 'stand-in item_foo', number: 1000)
      @item_bar = DoubleDouble::Expense.create!(name: 'stand-in item_bar', number: 1001)
    end

    it "should not be valid without an amount" do
      amt = DoubleDouble::CreditAmount.new.tap do |credit_amt|
        credit_amt.amount = nil
        credit_amt.account = @cash
        credit_amt.entry = @dummy_entry
      end
      expect(amt).to_not be_valid
    end

    it "should not be valid with an amount of 0" do
      amt = DoubleDouble::CreditAmount.new.tap do |credit_amt|
        credit_amt.amount = 0
        credit_amt.account = @cash
        credit_amt.entry = @dummy_entry
      end
      expect(amt).to_not be_valid
    end

    it "should not be valid without a entry" do
      amt = DoubleDouble::CreditAmount.new.tap do |credit_amt|
        credit_amt.amount = 9
        credit_amt.account = @cash
        credit_amt.entry = nil
      end
      expect(amt).to_not be_valid
    end

    it "should not be valid without an account" do
      amt = DoubleDouble::CreditAmount.new.tap do |credit_amt|
        credit_amt.amount = 9
        credit_amt.account = nil
        credit_amt.entry = @dummy_entry
      end
      expect(amt).to_not be_valid
    end
    
    it "should be sensitive to 'context' when calculating balances, if supplied" do
      amount_job = 111
      amount_po  = 222
      amount_no_context = 333
      Entry.create!(
          description: 'Amount for job',
          debits:  [{account: 'Cash', amount: amount_job}], 
          credits: [{account: 'Loan', amount: amount_job, context: @job}])
      Entry.create!(
          description: 'Amount for PO',
          debits:  [{account: 'Cash', amount: amount_po}], 
          credits: [{account: 'Loan', amount: amount_po, context: @po}])
      Entry.create!(
          description: 'Amount with no context',
          debits:  [{account: 'Cash', amount: amount_no_context}], 
          credits: [{account: 'Loan', amount: amount_no_context}])
      expect(@loan.credits_balance({context: @job})).to eq(amount_job)
      expect(@loan.credits_balance({context: @po})).to  eq(amount_po)
      expect(@loan.credits_balance).to                  eq(amount_job + amount_po + amount_no_context)
    end

    it "should be sensitive to 'subcontext' when calculating balances, if supplied" do
      amount_foo = 444
      amount_bar = 555
      Entry.create!(
          description: 'Amount for subcontext foo with context job',
          debits:  [{account: 'Cash', amount: amount_foo}], 
          credits: [{account: 'Loan', amount: amount_foo, context: @job, subcontext: @item_foo}])
      Entry.create!(
          description: 'Amount for subcontext foo with context PO',
          debits:  [{account: 'Cash', amount: amount_foo}], 
          credits: [{account: 'Loan', amount: amount_foo, context: @po, subcontext: @item_foo}])
      Entry.create!(
          description: 'Amount for subcontext bar with context PO',
          debits:  [{account: 'Cash', amount: amount_bar}], 
          credits: [{account: 'Loan', amount: amount_bar, context: @po, subcontext: @item_bar}])
      expect(@loan.credits_balance({context: @po, subcontext: @item_foo})).to eq(amount_foo)
      expect(@loan.credits_balance({context: @po, subcontext: @item_bar})).to eq(amount_bar)
      expect(@loan.credits_balance({subcontext: @item_foo})).to eq(amount_foo * 2)
      expect(Account.trial_balance).to eq(0)
    end
  end
end