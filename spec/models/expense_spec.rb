module DoubleDouble
  describe Expense do

    it_behaves_like "all account types" do
      let(:account_type) {:expense}
    end

    it_behaves_like "a left side account type" do
      let(:left_side_account_type) {:expense}
    end
  end
end
