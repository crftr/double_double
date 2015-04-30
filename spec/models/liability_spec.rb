module DoubleDouble
  describe Liability do
    it_behaves_like "all account types" do
      let(:account_type) {:liability}
    end

    it_behaves_like "a normal credit account type" do
      let(:normal_credit_account_type) {:liability}
    end

    it "should create a proper Liability account" do
      expect { 
        DoubleDouble::Liability.create! name: 'Liability acct', number: 20
      }.to change(DoubleDouble::Liability, :count).by(1)
    end
  end
end