module DoubleDouble
  describe Revenue do

    it_behaves_like "all account types" do
      let(:account_type) {:revenue}
    end

    it_behaves_like "a normal credit account type" do
      let(:normal_credit_account_type) {:revenue}
    end

    it "should create a proper Revenue account" do
      -> { DoubleDouble::Revenue.create! name: 'Revenue acct', number: 20
      }.should change(DoubleDouble::Revenue, :count).by(1)
    end
  end
end