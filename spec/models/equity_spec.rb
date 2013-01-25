module DoubleDouble
  describe Equity do

    it_behaves_like "all account types" do
      let(:account_type) {:equity}
    end

    it_behaves_like "a right side account type" do
      let(:right_side_account_type) {:equity}
    end

    it "should report a balance for the equity account" do
      equity = FactoryGirl.create(:equity)
      FactoryGirl.create(:credit_amount, :account => equity)
      equity.balance.should > 0
      equity.balance.should be_kind_of(Money)
    end

    it "should report a balance for the class of accounts" do
      equity = FactoryGirl.create(:equity)
      FactoryGirl.create(:credit_amount, :account => equity)
      Equity.should respond_to(:balance)
      Equity.balance.should > 0
      Equity.balance.should be_kind_of(Money)
    end
  end
end
