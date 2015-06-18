require 'database_cleaner'
require 'double_double'
require 'factory_girl'

# Create an in-memory database and run our template migration
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Migration.verbose = false

require_relative './../lib/generators/double_double/install/templates/create_double_double'
CreateDoubleDouble.new.change

# Require other test related files which aren't loaded by default
Dir["./spec/factories/*.rb"].each {|f| require f}
Dir["./spec/support/*.rb"].each   {|f| require f}

RSpec.configure do |config|
  config.order = 'random'

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
