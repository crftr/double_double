module DoubleDouble
  describe Expense do

    it_behaves_like "all account types" do
      let(:account_type) {:expense}
    end

    it_behaves_like "a normal debit account type" do
      let(:normal_debit_account_type) {:expense}
    end

    it "should create a proper Expense account" do
      -> { DoubleDouble::Expense.create! name: 'Expense acct', number: 20
      }.should change(DoubleDouble::Expense, :count).by(1)
    end
  end
end
