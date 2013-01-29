module DoubleDouble
  describe Asset do
    
    it_behaves_like "all account types" do
      let(:account_type) {:asset}
    end

    it_behaves_like "a normal debit account type" do
      let(:normal_debit_account_type) {:asset}
    end

    it "should create a proper Asset account" do
      -> { DoubleDouble::Asset.create! name: 'Asset acct', number: 20
      }.should change(DoubleDouble::Asset, :count).by(1)
    end
  end
end
