module DoubleDouble
  describe Transaction do

    before(:each) do
      @cash = DoubleDouble::Asset.create!(name:'Cash', number: 11)
      @loan = DoubleDouble::Liability.create!(name:'Loan', number: 12)
    end

    it 'should create a transaction using the create! method' do
      -> {
        Transaction.create!(
          description: 'spec transaction 01',
          debits:  [{account: 'Cash', amount: 10}],
          credits: [{account: 'Loan', amount:  9},
                    {account: 'Loan', amount:  1}])
      }.should change(DoubleDouble::Transaction, :count).by(1)
    end

    it 'should not create a transaction using the build method' do
      -> {
        Transaction.build(
          description: 'spec transaction 01',
          debits:  [{account: 'Cash', amount: 100_000}],
          credits: [{account: 'Loan', amount: 100_000}])
      }.should change(DoubleDouble::Transaction, :count).by(0)
    end

    it 'should not be valid without a credit amount' do
      # No credit_amount element
      t1 = Transaction.build(
        description: 'spec transaction 01',
        debits:  [{account: 'Cash', amount: 100_000}])
      t1.should_not be_valid
      t1.errors['base'].should include('Transaction must have at least one credit amount')
      t1.errors['base'].should include('The credit and debit amounts are not equal')
      # An empty credit_amount element
      t2 = Transaction.build(
        description: 'spec transaction 01',
        debits:  [{account: 'Cash', amount: 100_000}],
        credits: [])
      t2.should_not be_valid
      t2.errors['base'].should include('Transaction must have at least one credit amount') 
      t2.errors['base'].should include('The credit and debit amounts are not equal')
    end

    it 'should raise a RecordInvalid without a credit amount' do
      -> {
      Transaction.create!(
        description: 'spec transaction 01',
        debits:  [{account: 'Cash', amount: 100_000}],
        credits: [])
      }.should raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should not be valid with an invalid credit amount' do
      -> {
        Transaction.create!(
          description: 'spec transaction 01',
          credits: [{account: 'Loan', amount: nil}],
          debits:  [{account: 'Cash', amount: 100_000}])
      }.should raise_error(ArgumentError)
    end

    it 'should not be valid without a debit amount' do
      # No credit_amount element
      t1 = Transaction.build(
        description: 'spec transaction 01',
        credits:  [{account: 'Loan', amount: 100_000}])
      t1.should_not be_valid
      t1.errors['base'].should include('Transaction must have at least one debit amount')
      t1.errors['base'].should include('The credit and debit amounts are not equal')
      # An empty credit_amount element
      t2 = Transaction.build(
        description: 'spec transaction 01',
        credits: [{account: 'Loan', amount: 100_000}],
        debits:  [])
      t2.should_not be_valid
      t2.errors['base'].should include('Transaction must have at least one debit amount')
      t2.errors['base'].should include('The credit and debit amounts are not equal')
    end

    it 'should not be valid with an invalid debit amount' do
      -> {
        Transaction.create!(
          description: 'spec transaction 01',
          credits: [{account: 'Cash', amount: 100_000}],
          debits:  [{account: 'Loan', amount: nil}])
      }.should raise_error(ArgumentError)
    end

    it 'should not be valid without a description' do
      t = Transaction.build(
          description: '',
          debits:  [{account: 'Cash', amount: 100_000}],
          credits: [{account: 'Loan', amount: 100_000}])
      t.should_not be_valid
      t.errors[:description].should == ["can't be blank"]
    end

    it 'should require the debit and credit amounts to cancel' do
      t = Transaction.build(
        description: 'spec transaction 01',
        credits: [{account: 'Cash', amount: 100_000}],
        debits:  [{account: 'Loan', amount:  99_999}])
      t.should_not be_valid
      t.errors['base'].should == ['The credit and debit amounts are not equal']
    end

    describe 'context references' do
      it 'should allow a transaction to be built describing the context in the hash' do
        Transaction.create!(
          description: 'Sold some widgets',
          debits:  [{account: 'Cash', amount: 60, context_id: 55, context_type: 'Campaign'},
                    {account: 'Cash', amount: 40, context_id: 66, context_type: 'Campaign'}], 
          credits: [{account: 'Loan', amount: 45},
                    {account: 'Loan', amount:  5},
                    {account: 'Loan', amount: 50, context_id: 55, context_type: 'Campaign'}])
        Amount.by_context(55, 'Campaign').count.should eq(2)
        Amount.by_context(66, 'Campaign').count.should eq(1)
        @cash.debits_balance(context_id: 55, context_type: 'Campaign').should eq(60)
        @cash.debits_balance(context_id: 66, context_type: 'Campaign').should eq(40)
      end

      it 'should not create a context association unless both ID and TYPE are present' do
        Transaction.create!(
          description: 'Sold some widgets',
          debits:  [{account: 'Cash', amount: 60, context_id:  55, context_type: nil},
                    {account: 'Cash', amount: 40, context_id: nil, context_type: 'Campaign'}], 
          credits: [{account: 'Loan', amount: 45},
                    {account: 'Loan', amount:  5},
                    {account: 'Loan', amount: 50, context_id:  55, context_type: 'Campaign'}])
        Amount.by_context(55, 'Campaign').count.should eq(1)
        Amount.by_context(66, 'Campaign').count.should eq(0)
        @cash.debits_balance(context_id: 55, context_type: 'Campaign').should eq(0)
      end      
    end
  end
end
