module DoubleDouble
  describe Liability do

    it_behaves_like "all account types" do
      let(:account_type) {:liability}
    end

    it_behaves_like "a right side account type" do
      let(:right_side_account_type) {:liability}
    end

    it "should report a balance for the liability account" do
      liability = FactoryGirl.create(:liability)
      FactoryGirl.create(:credit_amount, :account => liability)
      liability.balance.should > 0
      liability.balance.should be_kind_of(Money)
    end

    it "should report a balance for the class of accounts" do
      liability = FactoryGirl.create(:liability)
      FactoryGirl.create(:credit_amount, :account => liability)
      Liability.should respond_to(:balance)
      Liability.balance.should > 0
      Liability.balance.should be_kind_of(Money)
    end
  end
end