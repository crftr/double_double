module DoubleDouble
  describe Asset do

    it_behaves_like "all account types" do
      let(:account_type) {:asset}
    end

    it_behaves_like "a left side account type" do
      let(:left_side_account_type) {:asset}
    end

    it "should report a balance for the asset account" do
      asset = FactoryGirl.create(:asset)
      FactoryGirl.create(:debit_amount, :account => asset)
      asset.balance.should > 0
      asset.balance.should be_kind_of(Money)
    end

    it "should report a balance for the class of accounts" do
      asset = FactoryGirl.create(:asset)
      FactoryGirl.create(:debit_amount, :account => asset)
      Asset.should respond_to(:balance)
      Asset.balance.should > 0
      Asset.balance.should be_kind_of(Money)
    end
  end
end
