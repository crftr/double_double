module DoubleDouble
  describe TransactionType do

    it 'should create a TransactionType using the create! method' do
      -> {
        TransactionType.create!(description: '123456')
      }.should change(DoubleDouble::TransactionType, :count).by(1)
    end

    it 'should not be valid without a description' do
      -> {
        TransactionType.create!(description: '')
      }.should raise_error(ActiveRecord::RecordInvalid)
      t = TransactionType.new(description: '')
      t.should_not be_valid
    end

    it 'should not be valid without a long-enough description' do
      -> {
        TransactionType.create!(description: '12345')
      }.should raise_error(ActiveRecord::RecordInvalid)
      t = TransactionType.new(description: '12345')
      t.should_not be_valid
    end
  end
end
