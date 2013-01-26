# Asset and Expense account types

shared_examples "a left side account type" do
  describe "<<" do
    
    it "should report a POSITIVE balance when an account is DEBITED" do
      account        = FactoryGirl.create(left_side_account_type)
      contra_account = FactoryGirl.create(left_side_account_type, :contra => true)
      t = FactoryGirl.build(:transaction)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: 75, account: account)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: 75, account: contra_account)
      t.save
      account.balance.should        > 0
      contra_account.balance.should > 0
    end

    it "should report a NEGATIVE balance when an account is CREDITED" do
      account        = FactoryGirl.create(left_side_account_type)
      contra_account = FactoryGirl.create(left_side_account_type, :contra => true)
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: 75, account: account)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: 75, account: contra_account)
      t.save
      account.balance.should        < 0
      contra_account.balance.should < 0
    end

    it "should report a NEGATIVE balance across the account type when CREDITED
     and using an unrelated type for the balanced side transaction" do
      account       = FactoryGirl.create(left_side_account_type)
      other_account = FactoryGirl.create("not_#{left_side_account_type}".to_sym)
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: 50, account: account)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: 50, account: other_account)
      t.save
      DoubleDouble.const_get(left_side_account_type.to_s.capitalize).should respond_to(:balance)
      DoubleDouble.const_get(left_side_account_type.to_s.capitalize).balance.should < 0
      DoubleDouble.const_get(left_side_account_type.to_s.capitalize).balance.should be_kind_of(Money)
    end

    it "should report a POSITIVE balance across the account type when DEBITED
     and using an unrelated type for the balanced side transaction" do
      account       = FactoryGirl.create(left_side_account_type)
      other_account = FactoryGirl.create("not_#{left_side_account_type}".to_sym)
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: 50, account: other_account)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: 50, account: account)
      t.save
      DoubleDouble.const_get(left_side_account_type.to_s.capitalize).should respond_to(:balance)
      DoubleDouble.const_get(left_side_account_type.to_s.capitalize).balance.should > 0
      DoubleDouble.const_get(left_side_account_type.to_s.capitalize).balance.should be_kind_of(Money)
    end

    it "should return the balance with respect to project_id, if project_id is supplied" do
      acct1         = FactoryGirl.create(left_side_account_type)
      acct2         = FactoryGirl.create(left_side_account_type)
      other_account = FactoryGirl.create("not_#{left_side_account_type}".to_sym)
      a1 = rand(1_000_000_000)
      a2 = rand(1_000_000_000)
      a3 = rand(1_000_000_000)
      a4 = rand(1_000_000_000)
      pid1 = 100
      pid2 = 200

      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(a1), account: acct1, project_id: pid1)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(a1), account: other_account)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(a2), account: acct1, project_id: pid1)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(a2), account: other_account)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(a3), account: acct1, project_id: pid2)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(a3), account: other_account)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(a3), account: acct1)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(a3), account: other_account)
      t.save

      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(a4), account: other_account)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(a4), account: acct1, project_id: pid1)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(a2), account: other_account)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(a2), account: acct1, project_id: pid1)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(a3), account: other_account)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(a3), account: acct1, project_id: pid2)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(a3), account: other_account)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(a3), account: acct1)
      t.save

      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(a4), account: other_account)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(a4), account: acct2, project_id: pid1)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(a2), account: other_account)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(a2), account: acct2, project_id: pid1)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(a3), account: other_account)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(a3), account: acct2, project_id: pid2)
      t.save
      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: Money.new(a3), account: other_account)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: Money.new(a3), account: acct2)
      t.save

      acct1.balance({project_id: pid1}).should == Money.new((a4 + a2) - (a1 + a2))
      acct1.balance({project_id: pid2}).should == Money.new(a3 - a3)
      acct1.balance.should                     == Money.new((a4 + a2 + a3 + a3) - (a1 + a2 + a3 + a3))
      
      acct2.balance({project_id: pid1}).should == Money.new((a4 + a2))
      acct2.balance({project_id: pid2}).should == Money.new(a3)
      acct2.balance.should                     == Money.new((a4 + a2 + a3 + a3))
    end
  end
end