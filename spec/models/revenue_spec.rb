module DoubleDouble
  describe Revenue do

    it_behaves_like "all account types" do
      let(:account_type) {:revenue}
    end

    it_behaves_like "a right side account type" do
      let(:right_side_account_type) {:revenue}
    end

    it "should report a balance for the revenue account" do
      revenue = FactoryGirl.create(:revenue)
      FactoryGirl.create(:credit_amount, :account => revenue)
      revenue.balance.should > 0
      revenue.balance.should be_kind_of(Money)
    end

    it "should report a balance for the class of accounts" do
      revenue = FactoryGirl.create(:revenue)
      FactoryGirl.create(:credit_amount, :account => revenue)
      Revenue.should respond_to(:balance)
      Revenue.balance.should > 0
      Revenue.balance.should be_kind_of(Money)
    end

    it "a contra account should reverse the normal balance" do
      contra_revenue = FactoryGirl.build(:revenue, :contra => true)
      # the odd amount below is because factories create a revenue credit_amount
      FactoryGirl.create(:debit_amount, :account => contra_revenue, :amount => Money.new(473))
      contra_revenue.balance.should > 0
      Revenue.balance.should == 0
    end
  end
end