module DoubleDouble
  describe Expense do

    it_behaves_like "all account types" do
      let(:account_type) {:expense}
    end

    it_behaves_like "a left side account type" do
      let(:left_side_account_type) {:expense}
    end

    it "should report a balance for the expense account" do
      expense = FactoryGirl.create(:expense)
      FactoryGirl.create(:debit_amount, :account => expense)
      expense.balance.should > 0
      expense.balance.should be_kind_of(Money)
    end

    it "should report a balance for the class of accounts" do
      expense = FactoryGirl.create(:expense)
      FactoryGirl.create(:debit_amount, :account => expense)
      Expense.should respond_to(:balance)
      Expense.balance.should > 0
      Expense.balance.should be_kind_of(Money)
    end
  end
end
