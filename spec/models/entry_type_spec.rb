module DoubleDouble
  describe EntryType do

    it 'should create a EntryType using the create! method' do
      -> {
        EntryType.create!(description: '123456')
      }.should change(DoubleDouble::EntryType, :count).by(1)
    end

    it 'should not be valid without a description' do
      -> {
        EntryType.create!(description: '')
      }.should raise_error(ActiveRecord::RecordInvalid)
      t = EntryType.new(description: '')
      t.should_not be_valid
    end

    it 'should not be valid without a long-enough description' do
      -> {
        EntryType.create!(description: '12345')
      }.should raise_error(ActiveRecord::RecordInvalid)
      t = EntryType.new(description: '12345')
      t.should_not be_valid
    end

    it 'should return the description as the to_s method' do
      t = EntryType.create!(description: 'foobarbaz')
      t.to_s.should == t.description
    end
  end
end
