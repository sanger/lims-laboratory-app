require 'lims-api/core_action_resource'
require 'lims-api/resources/container_to_uuid'

require 'lims-laboratory-app/laboratory/plate/transfer_plates_to_fluidigm'

module Lims::LaboratoryApp
  module Laboratory
    class Plate
      class TransferPlatesToFluidigmResource < Lims::Api::CoreActionResource

        include Lims::Api::Resources::ContainerToUuid

      end
    end
  end
end
