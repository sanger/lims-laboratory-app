# Model requirements
require 'lims-laboratory-app/laboratory/spin_column/all'

module Lims::LaboratoryApp
  module Laboratory
    shared_context "spin column factory" do
      def new_aliquot(q=1, i=1)
        aliquot = Aliquot.new(:sample => new_sample(i), :quantity => q)
      end

      def new_sample(i=1)
        Sample.new(:name => "Sample ##{i}")
      end

      def new_spin_column_with_samples(sample_nb=5, quantity=100, volume=100)
        SpinColumn.new.tap do |spin_column|
          1.upto(sample_nb) do |i|
            spin_column <<  new_aliquot(quantity, i)
          end
          spin_column << L::Aliquot.new(:type => L::Aliquot::Solvent, :quantity => volume) if volume
        end
      end

      def new_empty_spin_column
        SpinColumn.new
      end
    end
  end
end
