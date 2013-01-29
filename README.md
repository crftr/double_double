# double_double
[![Build Status](https://travis-ci.org/crftr/double_double.png)](https://travis-ci.org/crftr/double_double)
[![Dependency Status](https://gemnasium.com/crftr/double_double.png)](https://gemnasium.com/crftr/double_double)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/crftr/double_double)

A double-entry accounting system.  Currency-agnostic but insistent on using integers through the Money gem (see *[stackoverflow: Float or Decimal?][1]*).

[1]: http://stackoverflow.com/q/61872/18213

## Installation

### Gem

Add this line to your application's Gemfile:

    gem 'double_double'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install double_double

### Database structure

Create the expected database structure.  If using Rails, generate a migration:

    $ rails generate migration CreateDoubleDouble

Edit the migration to match:

```ruby
class CreateDoubleDouble < ActiveRecord::Migration
  def change
    create_table :double_double_accounts do |t|
      t.integer :number,        null: false
      t.string  :name,          null: false
      t.string  :type,          null: false
      t.boolean :contra,        default: false
    end
    add_index :double_double_accounts, [:name, :type]

    create_table :double_double_transactions do |t|
      t.string :description
      t.references :transaction_type
      t.timestamps
    end
    add_index :double_double_transactions, :transaction_type_id

    create_table :double_double_transaction_types do |t|
      t.integer :number,        null: false
      t.string :description,    null: false
    end
    add_index :double_double_transaction_types, :number

    create_table :double_double_amounts do |t|
      t.string :type
      t.references :account
      t.references :transaction
      t.references :context,    polymorphic: true
      t.references :initiator,  polymorphic: true
      t.references :accountee,  polymorphic: true
      
      t.integer :amount_cents, limit: 8, default: 0, null: false
      t.string  :currency
    end
    add_index :double_double_amounts, :context_id
    add_index :double_double_amounts, :context_type
    add_index :double_double_amounts, :initiator_id
    add_index :double_double_amounts, :initiator_type
    add_index :double_double_amounts, :accountee_id
    add_index :double_double_amounts, :accountee_type
    add_index :double_double_amounts, :type
    add_index :double_double_amounts, [:account_id, :transaction_id]
    add_index :double_double_amounts, [:transaction_id, :account_id]
  end
end
```

Rake the new migration

    $ rake db:migrate

## Overview

### Accounts

Account Type              | Normal Balance | Description                                        | Example Uses 
------------------------- | -------------- | -------------------------------------------------- | -------------------------------------------
`DoubleDouble::Asset`     | Debit          | Resources owned or controlled                      | Cash, Office Computers, Grandma's Jewelry
`DoubleDouble::Liability` | Credit         | Obligations                                        | Accounts Payable, Bank Loan
`DoubleDouble::Equity`    | Credit         | The claim to assets after all liabilities are paid | Paid-In Capital, Dividends, Retained Earnings
`DoubleDouble::Revenue`   | Credit         | Income                                             | Sales, Service Income, Interest Income
`DoubleDouble::Expense`   | Debit          | Expenditures                                       | Office Supplies, Utilities, Salaries, Rent

### Amounts & Transactions

...

## Usage

TODO: Write usage instructions here

## Tests

All code is backed by Rspec tests.  Clone this repository and either `rspec spec` or `rake spec` if Rake is installed.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes & tests (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Notes

double_double was influenced by mbulat's plutus project and regularly working with quickbooks.

