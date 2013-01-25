# Asset and Expense account types

shared_examples "a left side account type" do
  describe "<<" do
    it "should return the balance with respect to project_id, if project_id is supplied" do
      @acct1 = FactoryGirl.create(left_side_account_type)
      @a1 = rand(1...1_000_000_000)
      @a2 = rand(1...1_000_000_000)
      @a3 = rand(1...1_000_000_000)
      @a4 = rand(1...1_000_000_000)
      @pid1 = 100
      @pid2 = 200

      FactoryGirl.create(:credit_amount, account: @acct1, amount: Money.new(@a1),  project_id: @pid1)
      FactoryGirl.create(:credit_amount, account: @acct1, amount: Money.new(@a2),  project_id: @pid1)
      FactoryGirl.create(:credit_amount, account: @acct1, amount: Money.new(@a3),  project_id: @pid2)
      FactoryGirl.create(:credit_amount, account: @acct1, amount: Money.new(@a3))

      FactoryGirl.create(:debit_amount, account: @acct1, amount: Money.new(@a4),  project_id: @pid1)
      FactoryGirl.create(:debit_amount, account: @acct1, amount: Money.new(@a2),  project_id: @pid1)
      FactoryGirl.create(:debit_amount, account: @acct1, amount: Money.new(@a3),  project_id: @pid2)
      FactoryGirl.create(:debit_amount, account: @acct1, amount: Money.new(@a3))
      
      @acct2 = FactoryGirl.create(left_side_account_type)
      FactoryGirl.create(:debit_amount, account: @acct2, amount: Money.new(@a4),  project_id: @pid1)
      FactoryGirl.create(:debit_amount, account: @acct2, amount: Money.new(@a2),  project_id: @pid1)
      FactoryGirl.create(:debit_amount, account: @acct2, amount: Money.new(@a3),  project_id: @pid2)
      FactoryGirl.create(:debit_amount, account: @acct2, amount: Money.new(@a3))

      @acct1.balance({project_id: @pid1}).should == Money.new((@a4 + @a2) - (@a1 + @a2))
      @acct1.balance({project_id: @pid2}).should == Money.new(@a3 - @a3)
      @acct1.balance.should == Money.new((@a4 + @a2 + @a3 + @a3) - (@a1 + @a2 + @a3 + @a3))
      
      @acct2.balance({project_id: @pid1}).should == Money.new((@a4 + @a2))
      @acct2.balance({project_id: @pid2}).should == Money.new(@a3)
      @acct2.balance.should == Money.new((@a4 + @a2 + @a3 + @a3))
    end

    it "should report a POSITIVE balance when an account is debited" do
      account        = FactoryGirl.create(left_side_account_type)
      contra_account = FactoryGirl.create(left_side_account_type, :contra => true)

      t = FactoryGirl.build(:transaction)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: 75, account: account)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: 75, account: contra_account)
      t.save

      account.balance.should        > 0
      contra_account.balance.should > 0
    end

    it "should report a NEGATIVE balance when an account is credited" do
      account        = FactoryGirl.create(left_side_account_type)
      contra_account = FactoryGirl.create(left_side_account_type, :contra => true)

      t = FactoryGirl.build(:transaction)
      t.credit_amounts << FactoryGirl.create(:credit_amt, transaction: t, amount: 75, account: account)
      t.debit_amounts  << FactoryGirl.create(:debit_amt,  transaction: t, amount: 75, account: contra_account)
      t.save

      account.balance.should        < 0
      contra_account.balance.should < 0
    end
  end
end