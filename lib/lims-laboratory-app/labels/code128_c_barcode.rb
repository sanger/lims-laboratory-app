require 'common'
require 'lims-laboratory-app/labels/labellable'

module Lims::LaboratoryApp
  module Labels
    class Code128CBarcode
      include Labellable::Label
      Type = "code128-c-barcode"
    end
  end
end
