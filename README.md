# double_double
[![Build Status](https://travis-ci.org/crftr/double_double.png)](https://travis-ci.org/crftr/double_double)
[![Dependency Status](https://gemnasium.com/crftr/double_double.png)](https://gemnasium.com/crftr/double_double)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/crftr/double_double)

A double-entry accounting system.

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

## Usage

TODO: Write usage instructions here

## Name

The double double is the flagship In-N-Out cheeseburger.  Ask a southern-Californian.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Notes

double_double was heavily influenced by mbulat's plutus project and regularly working with quickbooks.