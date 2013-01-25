require 'database_cleaner'
require 'double_double'
require 'factory_girl'

require 'pry'

# Create an in-memory database and run our minimal migration
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false
@migration  = Class.new(ActiveRecord::Migration) do
  def change
    create_table :double_double_accounts do |t|
      t.integer :number,       null: false
      t.string :name
      t.string :type
      t.boolean :contra

      t.timestamps
    end
    add_index :double_double_accounts, [:name, :type]

    create_table :double_double_transactions do |t|
      t.string :description
      t.integer :commercial_document_id
      t.string :commercial_document_type
      t.references :transaction_type
      t.timestamps
    end
    add_index :double_double_transactions, [:commercial_document_id, :commercial_document_type], :name => "index_transactions_on_commercial_doc"
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
      t.references :project
      t.references :approving_user
      t.references :targeted_user
      t.integer :amount_cents, :limit => 8, :default => 0, :null => false
      t.string  :currency
    end 
    add_index :double_double_amounts, :project_id
    add_index :double_double_amounts, :approving_user_id
    add_index :double_double_amounts, :targeted_user_id
    add_index :double_double_amounts, :type
    add_index :double_double_amounts, [:account_id, :transaction_id]
    add_index :double_double_amounts, [:transaction_id, :account_id]
  end
end
@migration.new.migrate(:up)

# Load factories
Dir[File.expand_path(File.join(File.dirname(__FILE__),'factories','**','*.rb'))].each {|f| require f}

# Load left and right side rspec shared examples
Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end