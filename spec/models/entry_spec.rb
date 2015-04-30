module DoubleDouble
  describe Entry do
    before(:each) do
      @cash = DoubleDouble::Asset.create!(name:'Cash_11', number: 1011)
      @loan = DoubleDouble::Liability.create!(name:'Loan_12', number: 1012)
      # dummy objects to stand-in for accountees
      @user1 = DoubleDouble::Asset.create!(name:'some user1', number: 8991)
      @user2 = DoubleDouble::Asset.create!(name:'some user2', number: 8992)
      # dummy objects to stand-in for a context
      @campaign1 = DoubleDouble::Asset.create!(name:'campaign_test1', number: 9991)
      @campaign2 = DoubleDouble::Asset.create!(name:'campaign_test2', number: 9992)
    end

    it_behaves_like "it can run the README scenarios"

    it 'should create a Entry using the create! method' do
      expect {
        Entry.create!(
          description: 'spec entry 01',
          debits:  [{account: 'Cash_11', amount: 10}],
          credits: [{account: 'Loan_12', amount:  9},
                    {account: 'Loan_12', amount:  1}])
      }.to change(DoubleDouble::Entry, :count).by(1)
    end

    it 'should not create a Entry using the build method' do
      expect {
        Entry.build(
          description: 'spec entry 01',
          debits:  [{account: 'Cash_11', amount: 100_000}],
          credits: [{account: 'Loan_12', amount: 100_000}])
      }.to change(DoubleDouble::Entry, :count).by(0)
    end

    it 'should not be valid without a credit amount' do
      # No credit_amount element
      t1 = Entry.build(
        description: 'spec entry 01',
        debits:  [{account: 'Cash_11', amount: 100_000}])
      expect(t1).to_not be_valid
      expect(t1.errors['base']).to include('Entry must have at least one credit amount')
      expect(t1.errors['base']).to include('The credit and debit amounts are not equal')
      # An empty credit_amount element
      t2 = Entry.build(
        description: 'spec entry 01',
        debits:  [{account: 'Cash_11', amount: 100_000}],
        credits: [])
      expect(t2).to_not be_valid
      expect(t2.errors['base']).to include('Entry must have at least one credit amount')
      expect(t2.errors['base']).to include('The credit and debit amounts are not equal')
    end

    it 'should raise a RecordInvalid without a credit amount' do
      expect {
      Entry.create!(
        description: 'spec entry 01',
        debits:  [{account: 'Cash_11', amount: 100_000}],
        credits: [])
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should not be valid with an invalid credit amount' do
      expect {
        Entry.create!(
          description: 'spec entry 01',
          credits: [{account: 'Loan_12', amount: nil}],
          debits:  [{account: 'Cash_11', amount: 100_000}])
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should not be valid without a debit amount' do
      # No credit_amount element
      t1 = Entry.build(
        description: 'spec entry 01',
        credits:  [{account: 'Loan_12', amount: 100_000}])
      expect(t1).to_not be_valid
      expect(t1.errors['base']).to include('Entry must have at least one debit amount')
      expect(t1.errors['base']).to include('The credit and debit amounts are not equal')
      # An empty credit_amount element
      t2 = Entry.build(
        description: 'spec entry 01',
        credits: [{account: 'Loan_12', amount: 100_000}],
        debits:  [])
      expect(t2).to_not be_valid
      expect(t2.errors['base']).to include('Entry must have at least one debit amount')
      expect(t2.errors['base']).to include('The credit and debit amounts are not equal')
    end

    it 'should not be valid with an invalid debit amount' do
      expect {
        Entry.create!(
          description: 'spec entry 01',
          credits: [{account: 'Cash_11', amount: 100_000}],
          debits:  [{account: 'Loan_12', amount: nil}])
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should not be valid without a description' do
      t = Entry.build(
          description: '',
          debits:  [{account: 'Cash_11', amount: 100_000}],
          credits: [{account: 'Loan_12', amount: 100_000}])
      expect(t).to_not be_valid
      expect(t.errors[:description]).to eq(["can't be blank"])
    end

    it 'should require the debit and credit amounts to cancel' do
      t = Entry.build(
        description: 'spec entry 01',
        credits: [{account: 'Cash_11', amount: 100_000}],
        debits:  [{account: 'Loan_12', amount:  99_999}])
      expect(t).to_not be_valid
      expect(t.errors['base']).to eq(['The credit and debit amounts are not equal'])
    end

    describe 'entry reversing' do
      it "should negate the same non-reversed entry" do
        args_normal = {description: 'reverse test',
          debits:  [{account: 'Cash_11', amount: 10}],
          credits: [{account: 'Loan_12', amount:  9},
                    {account: 'Loan_12', amount:  1}]}
        args_reversed = args_normal.merge({reversed: true})
        Entry.create!(args_normal)
        expect(Account.named('Cash_11').balance).to eq(10)
        expect(Account.named('Loan_12').balance).to eq(10)
        Entry.create!(args_reversed)
        expect(Account.named('Cash_11').balance).to eq(0)
        expect(Account.named('Loan_12').balance).to eq(0)
      end
    end

    describe 'entry_types' do
      it 'should create a Entry with a EntryType of Unassigned if none is passed in' do
        t = Entry.build(
          description: 'spec entry 01',
          debits:  [{account: 'Cash_11', amount: 10}],
          credits: [{account: 'Loan_12', amount:  9},
                    {account: 'Loan_12', amount:  1}])
        expect(t.entry_type.description).to eq('unassigned')
      end

      it 'should create a Entry with a EntryType of Unassigned if none is passed in' do
        EntryType.create!(description: 'donation')
        t = Entry.build(
          description: 'spec entry 01',
          entry_type: EntryType.of(:donation),
          debits:  [{account: 'Cash_11', amount: 10}],
          credits: [{account: 'Loan_12', amount:  9},
                    {account: 'Loan_12', amount:  1}])
        expect(t.entry_type.description).to eq('donation')
      end
    end

    describe 'entry_types, when multiple types exist together' do
      it 'should segment based on entry type' do
        DoubleDouble::Liability.create!(name:'hotdogs', number: 1015)
        DoubleDouble::Liability.create!(name:'junk',    number: 1016)
        EntryType.create!(description: 'ketchup')
        EntryType.create!(description: 'onions')
        Entry.create!(
          description: 'processed ketchup',
          entry_type: EntryType.of(:ketchup),
          debits:  [{account: 'junk',    amount: 60, context: @campaign1, accountee: @user1}], 
          credits: [{account: 'hotdogs', amount: 60, context: @campaign1, accountee: @user1}])
        expect(DoubleDouble::Account.named('hotdogs').credits_balance({context: @campaign1, accountee: @user1, entry_type: EntryType.of(:ketchup)})).to eq(60)
        expect(DoubleDouble::Account.named('hotdogs').credits_balance({context: @campaign1, accountee: @user1, entry_type: EntryType.of(:onions)})).to eq(0)
        Entry.create!(
          description: 'processed onions',
          entry_type: EntryType.of(:onions),
          debits:  [{account: 'junk',    amount: 5, context: @campaign1, accountee: @user1}], 
          credits: [{account: 'hotdogs', amount: 5, context: @campaign1, accountee: @user1}])
        expect(DoubleDouble::Account.named('hotdogs').credits_balance({context: @campaign1, accountee: @user1, entry_type: EntryType.of(:ketchup)})).to eq(60)
        expect(DoubleDouble::Account.named('hotdogs').credits_balance({context: @campaign1, accountee: @user1, entry_type: EntryType.of(:onions)})).to eq(5)
      end
    end

    describe 'amount accountee references' do
      it 'should allow a Entry to be built describing the accountee in the hash' do
        Entry.create!(
          description: 'Sold some widgets',
          debits:  [{account: 'Cash_11', amount: 60, context: @campaign1, accountee: @user1},
                    {account: 'Cash_11', amount: 40, context: @campaign2, accountee: @user1},
                    {account: 'Cash_11', amount:  4, context: @campaign2, accountee: @user2}], 
          credits: [{account: 'Loan_12', amount: 45},
                    {account: 'Loan_12', amount:  9},
                    {account: 'Loan_12', amount: 50, context: @campaign1}])
        expect(Amount.by_accountee(@user1).count).to eq(2)
        expect(Amount.by_accountee(@user2).count).to eq(1)

        expect(@cash.debits_balance(context: @campaign1, accountee: @user1)).to eq(60)
        expect(@cash.debits_balance(context: @campaign1, accountee: @user2)).to eq(0)
        expect(@cash.debits_balance(context: @campaign2, accountee: @user1)).to eq(40)
        expect(@cash.debits_balance(context: @campaign2, accountee: @user2)).to eq(4)
        expect(@cash.debits_balance(context: @campaign2)).to eq(44)
        expect(Account.trial_balance).to eq(0)
      end  
    end

    describe 'amount context references' do
      it 'should allow a Entry to be built describing the context in the hash' do
        Entry.create!(
          description: 'Sold some widgets',
          debits:  [{account: 'Cash_11', amount: 60, context: @campaign1},
                    {account: 'Cash_11', amount: 40, context: @campaign2}], 
          credits: [{account: 'Loan_12', amount: 45},
                    {account: 'Loan_12', amount:  5},
                    {account: 'Loan_12', amount: 50, context: @campaign1}])
        expect(Amount.by_context(@campaign1).count).to eq(2)
        expect(Amount.by_context(@campaign2).count).to eq(1)

        expect(@cash.debits_balance(context: @campaign1)).to eq(60)
        expect(@cash.debits_balance(context: @campaign2)).to eq(40)
        expect(Account.trial_balance).to eq(0)
      end  
    end
  end
end