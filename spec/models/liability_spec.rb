module DoubleDouble
  describe Liability do

    it_behaves_like "all account types" do
      let(:account_type) {:liability}
    end

    it_behaves_like "a right side account type" do
      let(:right_side_account_type) {:liability}
    end

    it "should create a proper Liability account" do
      pending
    end
  end
end