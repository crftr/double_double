# Liability, Equity, and Revenue account types
shared_examples "a normal credit account type" do
  describe "<<" do

    describe "basic behavior" do

      before(:each) do
        @acct1         = FactoryGirl.create(normal_credit_account_type, name: 'acct1')
        @acct2_contra  = FactoryGirl.create(normal_credit_account_type, name: 'acct2_contra', :contra => true)
        @other_account = FactoryGirl.create("not_#{normal_credit_account_type}".to_sym, name: 'other_account')
      end
    
      it "should report a NEGATIVE balance when an account is debited" do
        DoubleDouble::Entry.create!(
          description: 'Sold some widgets',
          debits:  [{account: 'acct1', amount: Money.new(75)}], 
          credits: [{account: 'acct2_contra', amount: Money.new(75)}])
        @acct1.balance.should        < 0
        @acct2_contra.balance.should < 0
      end

      it "should report a POSITIVE balance when an account is credited" do
        DoubleDouble::Entry.create!(
          description: 'Sold some widgets',
          debits:  [{account: 'acct2_contra', amount: Money.new(75)}], 
          credits: [{account: 'acct1', amount: Money.new(75)}])
        @acct1.balance.should        > 0
        @acct2_contra.balance.should > 0
      end

      it "should report a POSITIVE balance across the account type when CREDITED
       and using an unrelated type for the balanced side entry" do
        DoubleDouble::Entry.create!(
          description: 'Sold some widgets',
          debits:  [{account: 'other_account', amount: Money.new(50)}], 
          credits: [{account: 'acct1', amount: Money.new(50)}])
        DoubleDouble.const_get(normal_credit_account_type.to_s.capitalize).should respond_to(:balance)
        DoubleDouble.const_get(normal_credit_account_type.to_s.capitalize).balance.should > 0
        DoubleDouble.const_get(normal_credit_account_type.to_s.capitalize).balance.should be_kind_of(Money)
      end

      it "should report a NEGATIVE balance across the account type when DEBITED
       and using an unrelated type for the balanced side entry" do
        DoubleDouble::Entry.create!(
          description: 'Sold some widgets',
          debits:  [{account: 'acct1', amount: Money.new(50)}], 
          credits: [{account: 'other_account', amount: Money.new(50)}])
        DoubleDouble.const_get(normal_credit_account_type.to_s.capitalize).should respond_to(:balance)
        DoubleDouble.const_get(normal_credit_account_type.to_s.capitalize).balance.should < 0
        DoubleDouble.const_get(normal_credit_account_type.to_s.capitalize).balance.should be_kind_of(Money)
      end
    end

    describe "context" do

      it "should return the balance with respect to context is supplied" do
        acct1         = FactoryGirl.create(normal_credit_account_type, name: 'acct1')
        acct2         = FactoryGirl.create(normal_credit_account_type, name: 'acct2')
        other_account = FactoryGirl.create("not_#{normal_credit_account_type}".to_sym, name: 'other_account')
        a1 = rand(1_000_000_000)
        a2 = rand(1_000_000_000)
        a3 = rand(1_000_000_000)
        a4 = rand(1_000_000_000)
        @project1 = FactoryGirl.create(normal_credit_account_type)
        @invoice555 = FactoryGirl.create(normal_credit_account_type)

        DoubleDouble::Entry.create!(
          description: 'Sold some widgets',
          debits:  [{account: 'other_account', amount: Money.new(a1)}], 
          credits: [{account: 'acct1',         amount: Money.new(a1), context: @project1}])
        DoubleDouble::Entry.create!(
          description: 'Sold something',
          debits:  [{account: 'other_account', amount: Money.new(a2)}], 
          credits: [{account: 'acct1',         amount: Money.new(a2), context: @project1}])
        DoubleDouble::Entry.create!(
          description: 'Sold something',
          debits:  [{account: 'other_account', amount: Money.new(a3)}], 
          credits: [{account: 'acct1',         amount: Money.new(a3), context: @invoice555}])
        DoubleDouble::Entry.create!(
          description: 'Sold something',
          debits:  [{account: 'other_account', amount: Money.new(a3)}], 
          credits: [{account: 'acct1',         amount: Money.new(a3)}])

        DoubleDouble::Entry.create!(
          description: 'Sold something',
          debits:  [{account: 'acct1',         amount: Money.new(a4), context: @project1}], 
          credits: [{account: 'other_account', amount: Money.new(a4)}])
        DoubleDouble::Entry.create!(
          description: 'Sold something',
          debits:  [{account: 'acct1',         amount: Money.new(a2), context: @project1}], 
          credits: [{account: 'other_account', amount: Money.new(a2)}])
        DoubleDouble::Entry.create!(
          description: 'Sold something',
          debits:  [{account: 'acct1',         amount: Money.new(a3), context: @invoice555}], 
          credits: [{account: 'other_account', amount: Money.new(a3)}])
        DoubleDouble::Entry.create!(
          description: 'Sold something',
          debits:  [{account: 'acct1',         amount: Money.new(a3)}], 
          credits: [{account: 'other_account', amount: Money.new(a3)}])

        DoubleDouble::Entry.create!(
          description: 'Sold something',
          debits:  [{account: 'acct2',         amount: Money.new(a4), context: @project1}], 
          credits: [{account: 'other_account', amount: Money.new(a4)}])
        DoubleDouble::Entry.create!(
          description: 'Sold something',
          debits:  [{account: 'acct2',         amount: Money.new(a2), context: @project1}], 
          credits: [{account: 'other_account', amount: Money.new(a2)}])
        DoubleDouble::Entry.create!(
          description: 'Sold something',
          debits:  [{account: 'acct2',         amount: Money.new(a3), context: @invoice555}], 
          credits: [{account: 'other_account', amount: Money.new(a3)}])
        DoubleDouble::Entry.create!(
          description: 'Sold something',
          debits:  [{account: 'acct2',         amount: Money.new(a3)}], 
          credits: [{account: 'other_account', amount: Money.new(a3)}])

        acct1.balance({context: @project1}).should   == Money.new((a1 + a2) - (a4 + a2))
        acct1.balance({context: @invoice555}).should == Money.new(a3 - a3)
        acct1.balance.should                         == Money.new((a1 + a2 + a3 + a3) - (a4 + a2 + a3 + a3))
        
        acct2.balance({context: @project1}).should   == Money.new(- (a4 + a2))
        acct2.balance({context: @invoice555}).should == Money.new(- a3)
        acct2.balance.should                         == Money.new(- (a4 + a2 + a3 + a3))
      end
    end
  end
end