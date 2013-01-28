module DoubleDouble
  describe Amount do

    it "should not allow creating an amount without a subtype" do
      cash = DoubleDouble::Asset.create!(name:'Cash', number: 11)
      amount = DoubleDouble::Amount.new(amount: 50, account: cash)
      amount.should_not be_valid
    end
  end
end
