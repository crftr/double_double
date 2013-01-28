module DoubleDouble
  describe Equity do
    
    it_behaves_like "all account types" do
      let(:account_type) {:equity}
    end

    it_behaves_like "a right side account type" do
      let(:right_side_account_type) {:equity}
    end

    it "should create a proper equity account" do
      -> { DoubleDouble::Equity.create! name: 'Equity acct', number: 20
      }.should change(DoubleDouble::Equity, :count).by(1)
    end
  end
end
