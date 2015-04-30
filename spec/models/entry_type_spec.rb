module DoubleDouble
  describe EntryType do
    it 'should create a EntryType using the create! method' do
      expect {
        EntryType.create!(description: '123456')
      }.to change(DoubleDouble::EntryType, :count).by(1)
    end

    it 'should not be valid without a description' do
      expect {
        EntryType.create!(description: '')
      }.to raise_error(ActiveRecord::RecordInvalid)
      t = EntryType.new(description: '')
      expect(t).to_not be_valid
    end

    it 'should not be valid without a long-enough description' do
      expect {
        EntryType.create!(description: '12345')
      }.to raise_error(ActiveRecord::RecordInvalid)
      t = EntryType.new(description: '12345')
      expect(t).to_not be_valid
    end

    it 'should return the description as the to_s method' do
      t = EntryType.create!(description: 'foobarbaz')
      expect(t.to_s).to eq(t.description)
    end
  end
end