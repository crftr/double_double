shared_examples "it can run the README scenarios" do
  describe "<<" do

    it 'should perform BASIC SCENARIO A correctly' do
      DoubleDouble::Asset.create! name:'Cash', number: 11
      DoubleDouble::Liability.create! name:'Grandpa Loan', number: 12
      DoubleDouble::Expense.create! name:'Spending', number: 13
      # Grandpa was kind enough to loan us $800 USD in cash for college textbooks.  To enter this we will require a entry which will affect both 'Cash' and 'Grandpa Loan'
      DoubleDouble::Entry.create!(
        description: 
          'We received a loan from Grandpa',
        debits:[
          {account: 'Cash', amount: '$800'}],
        credits:[
          {account: 'Grandpa Loan', amount: '$800'}])
      # We buy our college textbooks.  Luckily we had more than enough.
      DoubleDouble::Entry.create!(
        description: 
          'Purchase textbooks from bookstore',
        debits:[
          {account: 'Spending', amount: '$480'}],
        credits:[
          {account: 'Cash', amount: '$480'}])
      # How much cash is left?
      DoubleDouble::Account.named('Cash').balance.to_s.should eq("320.00")
      # We deceided that we wanted to return $320 of the loan.
      DoubleDouble::Entry.create!(
        description: 
          'Payed back $320 to Grandpa',
        debits:[
          {account: 'Grandpa Loan', amount: '$320'}],
        credits:[
          {account: 'Cash', amount: '$320'}])
      # How much do we still owed Grandpa?
      DoubleDouble::Account.named('Grandpa Loan').balance.to_s.should eq("480.00")
      # How much did we spend?
      DoubleDouble::Account.named('Spending').balance.to_s.should eq("480.00")
      # How much cash do we have left?
      DoubleDouble::Account.named('Cash').balance.to_s.should eq("0.00")
    end

    it 'should perform the REALISTIC SCENARIO correctly' do
      pending "TODO"
    end

    it 'should perform the COMPLEX SCENARIO correctly' do
      pending "TODO"
    end
  end
end