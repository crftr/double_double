require "generator_spec"

module DoubleDouble
  module Generators
    describe InstallGenerator, type: :generator do
      destination File.expand_path("../../tmp", __FILE__)

      before :all do
        prepare_destination
        run_generator
      end

      it "creates the installation database migration" do
        assert_file "db/migrate/create_double_double.rb", /class CreateDoubleDouble < ActiveRecord::Migration/
      end
    end
  end
end