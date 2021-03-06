require 'integrations/laboratory/spec_helper'

require 'lims-api/context_service'
require 'lims-core'
require 'lims-core/persistence/sequel'

require 'integrations/laboratory/lab_resource_shared'
require 'integrations/laboratory/resource_shared'

shared_context "expect empty plate" do
  # We don't use here Plate methods to generate the wells hash
  # because 
  let(:well_hash) { create_element_hash }
end

shared_context "expect plate JSON" do
  let (:expected_json) {
    path = "http://example.org/#{uuid}"
    { "plate" => {"actions" => {"read" => path,
        "update" => path,
        "delete" => path,
        "create" => path},
      "uuid" => uuid,
      "number_of_rows" => number_of_rows,
      "number_of_columns" => number_of_columns,
      "type" => plate_type,
      "location" => location,
      "wells" => well_hash}
    }
  }
end

shared_context "expect plate JSON with labels" do
  let(:expected_json) {
    path = "http://example.org/#{uuid}"
    { "plate" => {"actions" => {"read" => path,
        "update" => path,
        "delete" => path,
        "create" => path},
      "uuid" => uuid,
      "number_of_rows" => number_of_rows,
      "number_of_columns" => number_of_columns,
      "type" => plate_type,
      "location" => location,
      "wells" => well_hash,
      "labels" => actions_hash.merge(labellable_uuid_hash).merge(labels_hash)}
    }
  }
end

shared_context "parameters for empty plate" do
  let (:parameters) { { :plate => dimensions.merge(:location => location) } }
  let(:plate_type) { nil }
  include_context "expect empty plate"
end

shared_context "for plate with samples" do
  let(:parameters) { { :plate => dimensions.merge({
    :wells_description => wells_description, 
    :type => plate_type,
    :location => location}) }
  }
  include_context "with saved sample"
  include_context "with filled aliquots"
  let(:aliquot_type) { 'sample' }
  let(:aliquot_quantity) { 10 }
  let(:unit_type) { "mole" }
  let(:plate_type) { "plate type" }
  let(:wells_description) { { "C5" => [{"sample" => sample_uuid, "quantity" => aliquot_quantity, "type" => aliquot_type, "unit" => unit_type}] } }
  let(:wells_description_response) { { "C5" => aliquot_array } }
  let(:well_hash) { create_element_hash.merge(wells_description_response) }
end

shared_examples_for "with saved plate with samples" do
  include_context "has standard dimensions"
  let(:plate_type) { "plate type" }
  subject { described_class.new(:number_of_rows => number_of_rows,
                                :number_of_columns => number_of_columns,
                                :type => plate_type,
                                :location => location) }
  let (:sample_location) { :C5 }
  include_context "with sample in location"
end

shared_examples_for "with source wells" do
  let(:source_wells) {{
    "A1"=>[],"A2"=>[],"A3"=>[],"A4"=>[],"A5"=>[],"A6"=>[],"A7"=>[],"A8"=>[],"A9"=>[],"A10"=>[],"A11"=>[],"A12"=>[],
    "B1"=>[],"B2"=>[],"B3"=>[],"B4"=>[],"B5"=>[],"B6"=>[],"B7"=>[],"B8"=>[],"B9"=>[],"B10"=>[],"B11"=>[],"B12"=>[],
    "C1"=>[],"C2"=>[],"C3"=>[],"C4"=>[],"C5"=>aliquot_array,"C6"=>[],"C7"=>[],"C8"=>[],"C9"=>[],"C10"=>[],"C11"=>[],"C12"=>[],
    "D1"=>[],"D2"=>[],"D3"=>[],"D4"=>[],"D5"=>[],"D6"=>[],"D7"=>[],"D8"=>[],"D9"=>[],"D10"=>[],"D11"=>[],"D12"=>[],
    "E1"=>[],"E2"=>[],"E3"=>[],"E4"=>[],"E5"=>[],"E6"=>[],"E7"=>[],"E8"=>[],"E9"=>[],"E10"=>[],"E11"=>[],"E12"=>[],
    "F1"=>[],"F2"=>[],"F3"=>[],"F4"=>[],"F5"=>[],"F6"=>[],"F7"=>[],"F8"=>[],"F9"=>[],"F10"=>[],"F11"=>[],"F12"=>[],
    "G1"=>[],"G2"=>[],"G3"=>[],"G4"=>[],"G5"=>[],"G6"=>[],"G7"=>[],"G8"=>[],"G9"=>[],"G10"=>[],"G11"=>[],"G12"=>[],
    "H1"=>[],"H2"=>[],"H3"=>[],"H4"=>[],"H5"=>[],"H6"=>[],"H7"=>[],"H8"=>[],"H9"=>[],"H10"=>[],"H11"=>[],"H12"=>[]}}
end

shared_context "for plate with samples and labels" do
  include_context "for plate with samples"

  let(:label_parameters) {
    { :labellables => labellable }
  }
end

describe Lims::LaboratoryApp::Laboratory::Plate do
  include_context "use core context service"
  include_context "JSON"
  include_context "use generated uuid"
  let(:model) { "plates" }
  let(:location) { nil }

  context "#create" do
    include_context "has standard dimensions"
    context "with empty plates" do
      include_context "parameters for empty plate"
      include_context "expect plate JSON"
      it_behaves_like('creating a resource')
    end
    context "with plates with samples" do
      include_context "for plate with samples"
      include_context "expect plate JSON"
      it_behaves_like('creating a resource')
    end
    context "with plates with samples and labels" do
      include_context "for plate with samples and labels"
      include_context "resource with labels for the expected JSON"
      include_context "with labels"
      include_context "expect plate JSON with labels"
      it_behaves_like('creating a resource with a label on it')
    end
  end
  
  context "#update" do
    include_context "with saved plate with samples"
    include_context "for plate with samples"
    include_context "expect plate JSON"

    let(:path) { "/#{uuid}" }
    let(:aliquot_type) { "DNA" }
    let(:aliquot_quantity) { 10 }
    let(:parameters) { {:aliquot_type => aliquot_type, 
                        :aliquot_quantity => aliquot_quantity,
                        :type => plate_type} }

    it_behaves_like "updating a resource"
  end


  context "#page" do
    context "with 1 plate" do
      include_context "with saved plate with samples"
      let(:unit_type) { "mole" }
      let(:aliquot_type) { "sample" }
      let(:aliquot_quantity) { 10 }
      let (:viewed_aliquot_array) {
        path = "http://example.org/#{sample_uuid}"
        [ { "sample"=> {"actions" => { "read" => path,
          "update" => path,
          "delete" => path,
          "create" => path },
          "uuid" => sample_uuid,
          "name" => sample_name},
          "type" => aliquot_type,
          "quantity" => aliquot_quantity,
          "unit" => unit_type
      } ]
      }

      it "display a page" do
        path = "http://example.org/#{uuid}"
        get("plates/page=1").body.should match_json({
          "actions"=>{
            "read"=>"http://example.org/plates/page=1",
            "first"=>"http://example.org/plates/page=1",
            "last"=>"http://example.org/plates/page=-1"},
            "plates"=>[
              {"actions"=>{"read"=> path,
                           "update"=> path,
                           "delete"=> path,
                           "create"=> path,
            },
            "uuid" => uuid,
            "number_of_rows" => number_of_rows,
            "number_of_columns" => number_of_columns,
            "type" => plate_type,
            "location" => location,
            "wells"=>{
              "A1"=>[],"A2"=>[],"A3"=>[],"A4"=>[],"A5"=>[],"A6"=>[],"A7"=>[],"A8"=>[],"A9"=>[],"A10"=>[],"A11"=>[],"A12"=>[],
              "B1"=>[],"B2"=>[],"B3"=>[],"B4"=>[],"B5"=>[],"B6"=>[],"B7"=>[],"B8"=>[],"B9"=>[],"B10"=>[],"B11"=>[],"B12"=>[],
              "C1"=>[],"C2"=>[],"C3"=>[],"C4"=>[],"C5"=>viewed_aliquot_array,"C6"=>[],"C7"=>[],"C8"=>[],"C9"=>[],"C10"=>[],"C11"=>[],"C12"=>[],
              "D1"=>[],"D2"=>[],"D3"=>[],"D4"=>[],"D5"=>[],"D6"=>[],"D7"=>[],"D8"=>[],"D9"=>[],"D10"=>[],"D11"=>[],"D12"=>[],
              "E1"=>[],"E2"=>[],"E3"=>[],"E4"=>[],"E5"=>[],"E6"=>[],"E7"=>[],"E8"=>[],"E9"=>[],"E10"=>[],"E11"=>[],"E12"=>[],
              "F1"=>[],"F2"=>[],"F3"=>[],"F4"=>[],"F5"=>[],"F6"=>[],"F7"=>[],"F8"=>[],"F9"=>[],"F10"=>[],"F11"=>[],"F12"=>[],
              "G1"=>[],"G2"=>[],"G3"=>[],"G4"=>[],"G5"=>[],"G6"=>[],"G7"=>[],"G8"=>[],"G9"=>[],"G10"=>[],"G11"=>[],"G12"=>[],
              "H1"=>[],"H2"=>[],"H3"=>[],"H4"=>[],"H5"=>[],"H6"=>[],"H7"=>[],"H8"=>[],"H9"=>[],"H10"=>[],"H11"=>[],"H12"=>[]}}],
            "size"=>1
        })
      end
    end
    context do
      it "display an empty page" do
        #create a plate
        get("plates/page=1").body.should match_json({
          "actions"=>{
            "read"=>"http://example.org/plates/page=1",
            "first"=>"http://example.org/plates/page=1",
            "last"=>"http://example.org/plates/page=-1"},
            "plates"=>[],
            "size"=>0
        })
      end
    end
  end
  context "#transfer between source and target plates" do
    let(:url) { "/actions/plate_transfer" }
    context "with empty parameters" do
      let(:parameters) { {"plate_transfer" => {}} }
      let(:expected_json)  { {"errors" => {
        "source" => [
          "Source must not be blank"
        ],
          "target" => [
            "Target must not be blank"
        ],
          "transfer_map" => [
            "Transfer map must not be blank"
        ]}
      }}
      it_behaves_like "an invalid core action", 422  # Unprocessable entity
    end

    context "from a plate with sample" do
      let(:aliquot_type) { 'sample' }
      let(:aliquot_quantity) { 10 }
      let(:target_aliquot_quantity) { 10 }
      let(:unit_type) { "mole" }
      include_context "with filled aliquots"
      let(:transfer_map)  {{ "C5" => "B2" }}
      context "to an existing target" do
        let(:target_uuid) {     '11111111-2222-3333-1111-000000000000'.tap do |uuid|
          store.with_session do |session|
            plate = Lims::LaboratoryApp::Laboratory::Plate.new(:number_of_rows => 8, :number_of_columns => 12, :type => plate_type, :location => location)
            set_uuid(session, plate, uuid)
          end
        end}

        let(:target_aliquot_array) {
          path = "http://example.org/#{sample_uuid}"
          [ { "sample"=> {"actions" => { "read" => path,
                                         "update" => path,
                                         "delete" => path,
                                         "create" => path },
                                         "uuid" => sample_uuid,
                                         "name" => sample_name},
                                         "type" => aliquot_type,
#                                         "quantity" => target_aliquot_quantity,
                                       "unit" => unit_type} ]
        }
        let(:parameters) { {:plate_transfer => {
          :source_uuid => uuid, :target_uuid => target_uuid, :transfer_map => transfer_map, :aliquot_type => aliquot_type } }
        }
        include_context "with source wells"
          let(:target_wells) { {
            "A1"=>[],"A2"=>[],"A3"=>[],"A4"=>[],"A5"=>[],"A6"=>[],"A7"=>[],"A8"=>[],"A9"=>[],"A10"=>[],"A11"=>[],"A12"=>[],
            "B1"=>[],"B2"=>target_aliquot_array,"B3"=>[],"B4"=>[],"B5"=>[],"B6"=>[],"B7"=>[],"B8"=>[],"B9"=>[],"B10"=>[],"B11"=>[],"B12"=>[],
            "C1"=>[],"C2"=>[],"C3"=>[],"C4"=>[],"C5"=>[],"C6"=>[],"C7"=>[],"C8"=>[],"C9"=>[],"C10"=>[],"C11"=>[],"C12"=>[],
            "D1"=>[],"D2"=>[],"D3"=>[],"D4"=>[],"D5"=>[],"D6"=>[],"D7"=>[],"D8"=>[],"D9"=>[],"D10"=>[],"D11"=>[],"D12"=>[],
            "E1"=>[],"E2"=>[],"E3"=>[],"E4"=>[],"E5"=>[],"E6"=>[],"E7"=>[],"E8"=>[],"E9"=>[],"E10"=>[],"E11"=>[],"E12"=>[],
            "F1"=>[],"F2"=>[],"F3"=>[],"F4"=>[],"F5"=>[],"F6"=>[],"F7"=>[],"F8"=>[],"F9"=>[],"F10"=>[],"F11"=>[],"F12"=>[],
            "G1"=>[],"G2"=>[],"G3"=>[],"G4"=>[],"G5"=>[],"G6"=>[],"G7"=>[],"G8"=>[],"G9"=>[],"G10"=>[],"G11"=>[],"G12"=>[],
            "H1"=>[],"H2"=>[],"H3"=>[],"H4"=>[],"H5"=>[],"H6"=>[],"H7"=>[],"H8"=>[],"H9"=>[],"H10"=>[],"H11"=>[],"H12"=>[]}}
            let(:expected_json) {
              source_url = "http://example.org/#{uuid}"
              target_url = "http://example.org/#{target_uuid}"
              {:plate_transfer =>
                {:actions => {},
                  :user => "user@example.com",
                  :application => "application_id",
                  :result => { "plate" => { "actions" => {"read" => target_url,
                    "create" => target_url,
                    "update" => target_url,
                    "delete" => target_url} ,
                    "uuid" => target_uuid,
                    "type" => plate_type,
                    "number_of_rows" => number_of_rows,
                    "number_of_columns" => number_of_columns,
                    "location" => location,
                    "wells"=> target_wells}
                  },
                  :source => {"plate" => {"actions" => {"read" => source_url,
                    "create" => source_url,
                    "update" => source_url,
                    "delete" => source_url} ,
                    "uuid" => uuid,
                    "type" => plate_type,
                    "number_of_rows" => number_of_rows,
                    "number_of_columns" => number_of_columns,
                    "location" => location,
                    "wells"=> source_wells}},
                  :target => { "plate" => { "actions" => {"read" => target_url,
                    "create" => target_url,
                    "update" => target_url,
                    "delete" => target_url} ,
                    "uuid" => target_uuid,
                    "type" => plate_type,
                    "number_of_rows" => number_of_rows,
                    "number_of_columns" => number_of_columns,
                    "location" => location,
                    "wells"=> target_wells}},
                    :transfer_map => { "C5" => "B2" },
                    "aliquot_type" => aliquot_type
                }
              }
            }
                include_context "with saved plate with samples"
                it_behaves_like "a valid core action" do
                end
        end
      end
    end

  context "#transfer wells to tubes" do
    let(:url) { "/actions/transfer_wells_to_tubes" }
    context "with empty plates" do
      let(:parameters) { {:transfer_wells_to_tubes => {} } }
      let(:expected_json)  { {"errors" => {
        "plate" => [
          "Plate must not be blank"
        ],
          "well_to_tube_map" => [
            "Well to tube map must not be blank"
        ]
      }}}
      it_behaves_like "an invalid core action", 422  # Unprocessable entity
    end

    context "from a plate with sample" do
      include_context "with filled aliquots"
      context "to an existing target tube" do
        include_context "with source wells"
        let(:unit_type) { "mole" }
        let(:aliquot_quantity) { 0  }
        let(:aliquot_type) { 'sample' }
        let(:tube_uuid) { '22222222-3333-4444-1111-000000000000'.tap do |uuid|
            store.with_session do |session|
              tube = Lims::LaboratoryApp::Laboratory::Tube.new
              session << tube
              set_uuid(session, tube, uuid)
            end
          end
        }
        let(:well_to_tube_map)  {{ "C5" => tube_uuid }}
        let(:parameters) { {:transfer_wells_to_tubes => {
            :plate_uuid => uuid, :well_to_tube_map => well_to_tube_map } }
        }

        let(:expected_json) {
          source_url = "http://example.org/#{uuid}"
          { :transfer_wells_to_tubes =>
            {:actions => {},
            :user => "user@example.com",
            :application => "application_id",
            :plate => {"plate" => {"actions" => {"read" => source_url,
              "update" => source_url,
              "delete" => source_url,
              "create" => source_url},
              "uuid" => uuid,
              "number_of_rows" => number_of_rows,
              "number_of_columns" => number_of_columns,
              "type" => plate_type,
              "location" => location,
              "wells"=> source_wells}},
            :result => { "C5" => tube_uuid },
            :well_to_tube_map => { "C5" => tube_uuid },
            }
          }
        }
        include_context "with saved plate with samples"
        it_behaves_like "a valid core action" do
        end
      end
    end
  end
end
