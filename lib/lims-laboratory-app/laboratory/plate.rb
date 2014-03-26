require 'lims-laboratory-app/laboratory/locatable_resource'
require 'lims-laboratory-app/laboratory/container'

require 'facets/hash'
require 'facets/array'

module Lims::LaboratoryApp
  module Laboratory
    # A plate is a plate as seen in a laboratory, .i.e
    # a rectangular bits of platics with wells and some 
    # readable labels on it.
    # TODO add label behavior
    class Plate 
      include LocatableResource
      # Type contains the actual type of the plate.
      attribute :type, String, :required => false

      def attributes
        {type: @type,
          number_of_rows: @number_of_rows,
          number_of_columns: @number_of_columns,
          location: @location
        }
      end

      # creates the matrix of container elements (Wells),
      # which contains some chemical substances.
      matrix_of(:Well)

      # This should be set by the user.
      # We mock it to give pools by column
      # @return [Hash<String, Array<String>] pools pool name => list of wells name
      def pools
        1.upto(number_of_columns).mash do |c|
          [c, 1.upto(number_of_rows).map { |r| indexes_to_element_name(r-1,c-1) } ]
        end
      end
    end
  end
end
