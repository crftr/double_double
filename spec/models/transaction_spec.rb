module DoubleDouble
  describe Transaction do

    before(:each) do
      @acct       = FactoryGirl.create(:asset)
      @other_acct = FactoryGirl.create(:not_asset)
    end

    it "should create a transaction" do
      -> {
        t = FactoryGirl.build(:transaction)
        t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(123), account: @acct)
        t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(123), account: @other_acct)
        t.save!
      }.should change(DoubleDouble::Transaction, :count).by(1)
    end

    it "should not be valid without a credit amount" do
      t = FactoryGirl.build(:transaction)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(123), account: @other_acct)
      t.should_not be_valid
      t.errors['base'].should include("Transaction must have at least one credit amount")
    end

    it "should not be valid with an invalid credit amount" do
      -> {
        t = FactoryGirl.build(:transaction)
        t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: nil,            account: @acct)
        t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(123), account: @other_acct)
        t.save
      }.should raise_error(ArgumentError)
    end

    it "should not be valid without a debit amount" do
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(123), account: @acct)
      t.should_not be_valid
      t.errors['base'].should include("Transaction must have at least one debit amount")
    end

    it "should not be valid with an invalid debit amount" do
      -> {
        t = FactoryGirl.build(:transaction)
        t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(123), account: @acct)
        t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: nil,            account: @other_acct)
        t.save
      }.should raise_error(ArgumentError)
    end

    it "should not be valid without a description" do
      t = FactoryGirl.build(:transaction, description: nil)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(123), account: @acct)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(123), account: @other_acct)
      t.save
      t.should_not be_valid
      t.errors[:description].should == ["can't be blank"]
    end

    it "should require the debit and credit amounts to cancel" do
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(555), account: @acct)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(666), account: @other_acct)
      t.save
      t.should_not be_valid
      t.errors['base'].should == ["The credit and debit amounts are not equal"]
    end

    describe "the build class method" do

      before(:each) do
        @ar = FactoryGirl.create(:asset, :name => "Accounts Receivable")
        FactoryGirl.create(:revenue, :name => "Sales Revenue")
        FactoryGirl.create(:liability, :name =>  "Sales Tax Payable")
        FactoryGirl.create(:liability, :name =>  "Deposits")
      end

      it "should allow a transaction to be built describing the credit and debit_amounts with the MINIMAL hash" do
        transaction = Transaction.build(
          description: "Sold some widgets",
          debits: [
            {account: "Accounts Receivable", amount: 50}], 
          credits: [
            {account: "Sales Revenue",                    amount: 45},
            {account: "Sales Tax Payable",                amount:  5}])

        transaction.should be_valid
      end

      it "should allow a transaction to be built describing the context in the hash" do
        transaction = Transaction.build(
          description: "Sold some widgets",
          debits: [
            {account: "Accounts Receivable", amount: 60,            context_id: 55, context_type: 'Campaign'},
            {account: "Accounts Receivable", amount: 40,            context_id: 66, context_type: 'Campaign'}], 
          credits: [
            {account: "Sales Revenue",                  amount: 45},
            {account: "Sales Tax Payable",              amount:  5},
            {account: "Deposits",                       amount: 50, context_id: 55, context_type: 'Campaign'}])

        transaction.should be_valid
        transaction.save
        Amount.by_context(55, 'Campaign').count.should eq(2)
        Amount.by_context(66, 'Campaign').count.should eq(1)
        @ar.debits_balance(context_id: 55, context_type: 'Campaign').should eq(60)
        @ar.debits_balance(context_id: 66, context_type: 'Campaign').should eq(40)
      end
    end
  end
end
