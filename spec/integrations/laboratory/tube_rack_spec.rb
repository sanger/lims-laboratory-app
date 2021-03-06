require 'integrations/laboratory/spec_helper'

require 'lims-api/context_service'
require 'lims-core'
require 'lims-core/persistence/sequel'

require 'integrations/laboratory/lab_resource_shared'
require 'integrations/laboratory/plate_resource_shared'

require 'integrations/laboratory/resource_shared'


module Lims::LaboratoryApp::Laboratory
  shared_examples_for "with saved tube rack with tubes" do
    include_context "has standard dimensions"
    include_context "with tube and sample"

    def create_new_tube_rack(rack_uuid, tube_uuids, slots=["B5"])
      store.with_session do |session|
        tuberack = TubeRack.new(
          :number_of_rows => number_of_rows,
          :number_of_columns => number_of_columns,
          :location => location)
        slots.zip(tube_uuids).each do |slot, tube_uuid|
          tuberack[slot] = session[tube_uuid]
        end
        set_uuid(session, tuberack, rack_uuid)
      end
      rack_uuid
    end

    def create_new_sample(uuid, session)
      sample = Lims::LaboratoryApp::Laboratory::Sample.new("sample 1")
      set_uuid(session, sample, uuid)
      sample
    end

    def create_new_tubes_with_a_sample(tube_uuids = [], sample_uuids = [])
      store.with_session do |session|
        tube_uuids.zip(sample_uuids).each do |tube_uuid, sample_uuid|
          tube = Lims::LaboratoryApp::Laboratory::Tube.new(
            :type => "Eppendorf",
            :max_volume => 2)
          tube << Lims::LaboratoryApp::Laboratory::Aliquot.new(
            :sample => create_new_sample(sample_uuid, session),
            :type => "sample",
            :quantity => 10)
          set_uuid(session, tube, tube_uuid)
        end
      end
    end

    def get_aliquot_array(sample_uuid)
      path = "http://example.org/#{sample_uuid}"

      [ { "sample"=> {"actions" => { "read" => path,
              "create" => path,
              "update" => path,
              "delete" => path
               },
              "uuid" => sample_uuid,
              "name" => sample_name},
              "quantity" => aliquot_quantity,
              "type" => aliquot_type,
              "unit" => unit_type
        } 
      ]
    end
  end

  shared_examples_for "with tube and sample" do
    include_context "with saved sample"

    let(:aliquot_type) { "sample" }
    let(:aliquot_quantity) { 10 }
    let(:unit_type) { "mole" }
    let(:tube_type) { "Eppendorf" }
    let(:location) { nil }

    let(:tube_max_volume) { 2 }
    let(:tube) { Lims::LaboratoryApp::Laboratory::Tube.new(:type => tube_type, :max_volume => tube_max_volume) }
    let!(:tube_uuid) {
      '11111111-2222-3333-4444-999999999999'.tap do |uuid|
        store.with_session do |session|
          tube << Lims::LaboratoryApp::Laboratory::Aliquot.new(:sample => session[sample_uuid], 
                                                      :type => aliquot_type,
                                                      :quantity => aliquot_quantity)
          set_uuid(session, tube, uuid)
        end
      end
    }
  end


  shared_context "parameters for empty tube rack" do
    let(:parameters) { {:tube_rack => dimensions.merge(:location => location)} }
    let(:tubes_hash) { {} }
  end

  shared_context "for tube rack with tubes" do
    include_context "with filled aliquots"
    include_context "with tube and sample"
    let(:tubes) { {tube_location => tube_uuid} }
    let(:location) { nil }
    let(:parameters) { {:tube_rack => dimensions.merge(:tubes => tubes, :location => location)} }
    let(:tubes_hash) { 
      path = "http://example.org/#{tube_uuid}"
      {tube_location => 
       {"actions" => 
        {"read" => path,
        "create" => path,
        "update" => path,
        "delete" => path},
       "uuid" => tube_uuid,
       "location" => nil,
       "type" => tube_type,
       "max_volume" => tube_max_volume,
       "aliquots" => aliquot_array}}
    }
  end

  shared_context "expected tube rack JSON" do
    let(:expected_json) {
      path = "http://example.org/#{uuid}"
      {"tube_rack" => 
       {"actions" =>
        {"read" => path,
         "update" => path,
         "delete" => path,
         "create" => path},
         "uuid" => uuid,
         "number_of_rows" => number_of_rows,
         "number_of_columns" => number_of_columns,
         "location" => location,
         "tubes" => tubes_hash}}
    }
  end

  shared_context "with a target rack tube" do
    let(:target_tube_type) { "target type" }
    let(:target_tube_max_volume) { 5 }
    let(:target_tube_uuid) {
      "11111111-1111-1111-4444-666666666666".tap do |uuid|
        store.with_session do |session|
          tube = Lims::LaboratoryApp::Laboratory::Tube.new(:type => target_tube_type,
                                                  :max_volume => target_tube_max_volume)
          set_uuid(session, tube, uuid)
        end
      end
    }

    def create_new_target_tube_rack(rack_uuid, with_tube)
      store.with_session do |session|
        tuberack = TubeRack.new(
          :number_of_rows => number_of_rows,
          :number_of_columns => number_of_columns,
          :location => location)
        tuberack[target_location] = session[target_tube_uuid] if with_tube
        set_uuid(session, tuberack, rack_uuid)
      end
      rack_uuid
    end
  end

  shared_context "expected transfer actions JSON" do
    let(:expected_json) {
      source_url = "http://example.org/#{source_rack1_uuid}"
      target_url = "http://example.org/#{target_rack1_uuid}"
      {
        action_name => {
          :actions => {},
          :user => "user@example.com",
          :application => "application_id",
          :result => { 
            :tube_rack => { 
              :actions => {
                :read => target_url,
                :update => target_url,
                :delete => target_url,
                :create => target_url
              },
              :uuid => target_rack1_uuid,
              :number_of_rows => number_of_rows,
              :number_of_columns => number_of_columns,
              :location => location,
              :tubes => target_tubes}
          },
          :source => {
            :tube_rack => {
              :actions => {
                :read => source_url,
                :update => source_url,
                :delete => source_url,
                :create => source_url
              },
              :uuid => source_rack1_uuid,
              :number_of_rows => number_of_rows,
              :number_of_columns => number_of_columns,
              :location => location,
              :tubes => source_tubes}
          },
          :target => { 
            :tube_rack => { 
              :actions => {
                :read => target_url,
                :update => target_url,
                :delete => target_url,
                :create => target_url
              },
              :uuid => target_rack1_uuid,
              :number_of_rows => number_of_rows,
              :number_of_columns => number_of_columns,
              :location => location,
              :tubes => target_tubes}
          },
          action_map_name => transfer_map
        }
      }
    }
  end

  describe TubeRack do
    include_context "use core context service"
    include_context "JSON"
    let(:model) { "tube_racks" }
    let(:target_location) { "E3" }
    let(:source_rack_uuids) { ["11111111-2222-3333-4444-555555555550",
                               "11111111-2222-3333-4444-555555555551"]
    }
    let(:target_rack_uuids) { ["11111111-2222-3333-4444-666666666660",
                               "11111111-2222-3333-4444-666666666661"]
    }
    let(:location) { nil }

    context "#create" do
      include_context "has standard dimensions"

      context "with empty tube rack" do
        include_context "parameters for empty tube rack"
        include_context "expected tube rack JSON"
        it_behaves_like "creating a resource"
      end

      context "with tubes in the tube rack", :testt => true do
        let(:tube_location) { "A1" }
        include_context "for tube rack with tubes"
        include_context "expected tube rack JSON"
        it_behaves_like "creating a resource"
      end
    end


    context "#update" do
      include_context "with saved tube rack with tubes"
      include_context "expected tube rack JSON"
      include_context "for tube rack with tubes"

      let(:uuid) { create_new_tube_rack(source_rack_uuids[0], [tube_uuid]) }
      let(:tube_location) { "B5" }
      let(:path) { "/#{uuid}" }
      let(:aliquot_type) { "DNA" }
      let(:aliquot_quantity) { 10 }
      let(:location) { nil }
      let(:parameters) { {:aliquot_type => aliquot_type, :aliquot_quantity => aliquot_quantity, :location => location} }

      it_behaves_like "updating a resource"
    end


    context "#page" do
      let(:url) { "tube_racks/page=1" }
      let(:action_path) { "http://example.org/tube_racks" }

      let(:expected_page_json) {{
        "actions" => {
          "read" => "#{action_path}/page=1",
          "first" => "#{action_path}/page=1",
          "last" => "#{action_path}/page=-1"},
        "tube_racks" => expected_tube_racks,
        "size" => expected_size
      }}

      context "with no tube rack" do
        let(:expected_tube_racks) { [] }
        let(:expected_size) { 0 }
        it "displays an empty page" do
          get(url).body.should match_json(expected_page_json)
        end
      end

      context "with 1 tube rack" do
        include_context "with filled aliquots"
        let!(:uuid) { create_new_tube_rack(source_rack_uuids[0], [tube_uuid]) }
        let(:rack_action_path) { "http://example.org/#{uuid}" }
        let(:tube_action_path) { "http://example.org/#{tube_uuid}" }
        let(:viewed_tube) { 
                            {"actions" => 
                             {"read" => tube_action_path,
                              "update" => tube_action_path,
                              "delete" => tube_action_path,
                              "create" => tube_action_path},
                            "uuid" => tube_uuid,
                            "location" => nil,
                            "type" => tube_type,
                            "max_volume" => tube_max_volume,
                            "aliquots" => aliquot_array}}
        let(:expected_tube_racks) {[
           {"actions" => 
            {"read" => rack_action_path,
             "update" => rack_action_path,
             "delete" => rack_action_path,
             "create" => rack_action_path
            },
            "uuid" => uuid,
            "number_of_rows" => number_of_rows,
            "number_of_columns" => number_of_columns,
            "location" => nil,
            "tubes" => {"B5"=>viewed_tube}
            }]}
        let(:expected_size) { 1 }
        include_context "with saved tube rack with tubes"
        it "displays a page" do
          get(url).body.should match_json(expected_page_json)
        end
      end
    end


    context "#transfer" do
      include_context "with filled aliquots"
      let(:url) { "/actions/tube_rack_transfer" }

      context "with empty parameters" do
        let(:parameters) { {"tube_rack_transfer" => {} } }
        let(:expected_json) { {
          :errors => {
            "source"=> [
              "Source must not be blank"
            ],
              "target"=> [
                "Target must not be blank"
            ],
              "transfer_map"=> [
                "Transfer map must not be blank"
            ]
          }}}
        it_behaves_like "an invalid core action", 422
      end

      context "with correct parameters" do
        include_context "with saved tube rack with tubes"
        include_context "with a target rack tube"
        include_context "expected transfer actions JSON"

        let(:source_rack1_uuid) { create_new_tube_rack(source_rack_uuids[0], [tube_uuid]) }
        let(:target_rack1_uuid) { create_new_target_tube_rack(target_rack_uuids[0], true) }
        let(:transfer_map) { {"B5" => "E3"} }
        let(:action_name) { "tube_rack_transfer" }
        let(:action_map_name) { "transfer_map" }
        let(:parameters) { {
          :tube_rack_transfer => {
            :source_uuid => source_rack1_uuid,
            :target_uuid => target_rack1_uuid,
            :transfer_map => transfer_map}
        }}
        let(:remaining_aliquot_quantity) { 0 }
        let(:source_tubes) {
          path = "http://example.org/#{tube_uuid}"
          path_sample = "http://example.org/#{sample_uuid}"
          {
            "B5" => {"actions" => 
                     {"read" => path,
                      "create" => path,
                      "update" => path,
                      "delete" => path},
                      "uuid" => tube_uuid,
                      "location" => nil,
                      "type" => tube_type,
                      "max_volume" => tube_max_volume,
                      "aliquots" => [ { "sample"=> {"actions" => { "read" => path_sample,
                                                                   "create" => path_sample,
                                                                   "update" => path_sample,
                                                                   "delete" => path_sample
                                                                    },
                                                                   "uuid" => sample_uuid,
                                                                   "name" => sample_name},
                                                                   "quantity" => remaining_aliquot_quantity,
                                                                   "type" => aliquot_type,
                                                                   "unit" => unit_type} ]}}
        } 
        let(:target_tubes) {
          path = "http://example.org/#{target_tube_uuid}"
          {
            "E3" => {"actions" => 
                     {"read" => path,
                      "create" => path,
                      "update" => path,
                      "delete" => path},
                      "uuid" => target_tube_uuid,
                      "location" => nil,
                      "type" => target_tube_type,
                      "max_volume" => target_tube_max_volume,
                      "aliquots" => aliquot_array}}
        }
        it_behaves_like "a valid core action"
      end
    end

    context "#move" do
      include_context "with filled aliquots"
      let(:url) { "/actions/tube_rack_move" }
      let(:location) { nil }

      context "with no parameters" do
        let(:parameters) { {} }
        let(:expected_json) { {
          "errors" => {
            "tube_rack_move" => [
              "missing parameter"
            ]
        }}}
        it_behaves_like "an invalid core action", 422
      end
      context "with empty parameters" do
        let(:parameters) { { "tube_rack_move" => {} } }
        let(:expected_json) { {
          "errors" => {
            "moves" => [
              "Moves must not be blank"
            ]
        }}}
        it_behaves_like "an invalid core action", 422
      end

      context "with correct parameters" do
        context "a single tube rack to another tube rack move" do
          include_context "with saved tube rack with tubes"
          include_context "with a target rack tube"

          let(:source_rack1_uuid) { create_new_tube_rack(source_rack_uuids[0], [tube_uuid]) }
          let(:target_rack1_uuid) { create_new_target_tube_rack(target_rack_uuids[0], false) }
          let(:source_location) { "B5" }
          let(:moves) { [
            { "source_uuid" => source_rack1_uuid,
              "source_location" => source_location,
              "target_uuid" => target_rack1_uuid,
              "target_location" => "E9"
            }
            ]
          }
          let(:parameters) { { :tube_rack_move => { :moves => moves } } }
          let(:source_tubes) { {} }
          let(:target_tubes) {
            path = "http://example.org/#{tube_uuid}"
            {
              "E9" => {"actions" =>
                       {"read" => path,
                        "create" => path,
                        "update" => path,
                        "delete" => path},
                        "uuid" => tube_uuid,
                        "location" => nil,
                        "type" => tube_type,
                        "max_volume" => tube_max_volume,
                        "aliquots" => aliquot_array}}
          }

          let(:expected_json) {
            target_url = "http://example.org/#{target_rack1_uuid}"
            {
              :tube_rack_move => {
                :actions => {},
                :user => "user@example.com",
                :application => "application_id",
                :result => [{
                  "tube_rack" => {
                    "actions" => {
                      "read" => target_url,
                      "create" => target_url,
                      "update" => target_url,
                      "delete" => target_url,
                    },
                    "uuid" => target_rack1_uuid,
                    "number_of_rows" => number_of_rows,
                    "number_of_columns" => number_of_columns,
                    "location" => nil,
                    "tubes" => target_tubes}
                }],
                :moves => moves
              }
            }
          }

          it_behaves_like "a valid core action"
        end

        context "multiply tube rack to a tube rack move" do
          include_context "with saved tube rack with tubes"
          include_context "with a target rack tube"

          before do
            create_new_tubes_with_a_sample(tube_uuids_1, sample_uuids_1)
            create_new_tubes_with_a_sample(tube_uuids_2, sample_uuids_2)
          end
          let(:tube_uuids_1) {
            ['11111111-0000-3333-4444-111111111111',
             '11111111-0000-3333-4444-222222222222'
            ]
          }
          let(:tube_uuids_2) {
            ['11111111-0000-3333-4444-333333333333',
             '11111111-0000-3333-4444-444444444444'
            ]
          }
          let(:sample_uuids_1) {
            ['11111111-1111-3333-4444-111111111111',
             '11111111-1111-3333-4444-222222222222'
            ]
          }
          let(:sample_uuids_2) {
            ['11111111-1111-3333-4444-333333333333',
             '11111111-1111-3333-4444-444444444444'
            ]
          }
          let(:source_locations_rack1) { ["A1", "B2"] }
          let(:source_locations_rack2) { ["C5", "E8"] }
          let(:target_locations_rack1) { ["B9", "D4"] }
          let(:target_locations_rack2) { ["F3", "A9"] }
          let(:source_rack1_uuid) {
            create_new_tube_rack(source_rack_uuids[0], tube_uuids_1, source_locations_rack1)
          }
          let(:source_rack2_uuid) {
            create_new_tube_rack(source_rack_uuids[1], tube_uuids_2, source_locations_rack2)
          }
          let(:target_rack1_uuid) { create_new_target_tube_rack(target_rack_uuids[0], false) }
          let(:target_rack2_uuid) { create_new_target_tube_rack(target_rack_uuids[1], false) }
          let(:moves) { [
            { "source_uuid" => source_rack1_uuid,
              "source_location" => source_locations_rack1[0],
              "target_uuid" => target_rack1_uuid,
              "target_location" => target_locations_rack1[0]
            },
            { "source_uuid" => source_rack1_uuid,
              "source_location" => source_locations_rack1[1],
              "target_uuid" => target_rack2_uuid,
              "target_location" => target_locations_rack2[0]
            },
            { "source_uuid" => source_rack2_uuid,
              "source_location" => source_locations_rack2[0],
              "target_uuid" => target_rack1_uuid,
              "target_location" => target_locations_rack1[1]
            },
            { "source_uuid" => source_rack2_uuid,
              "source_location" => source_locations_rack2[1],
              "target_uuid" => target_rack2_uuid,
              "target_location" => target_locations_rack2[1]
            }
            ]
          }
          let(:parameters) { { :tube_rack_move => { :moves => moves } } }
          let(:source_tubes) { {} }
          let(:target1_tubes) {
            path1 = "http://example.org/#{tube_uuids_1[0]}"
            path2 = "http://example.org/#{tube_uuids_2[0]}"
            {
              target_locations_rack1[0] => {"actions" =>
                       {"read" => path1,
                        "create" => path1,
                        "update" => path1,
                        "delete" => path1},
                        "uuid" => tube_uuids_1[0],
                        "location" => nil,
                        "type" => tube_type,
                        "max_volume" => tube_max_volume,
                        "aliquots" => get_aliquot_array(sample_uuids_1[0])},
              target_locations_rack1[1] => {"actions" =>
                       {"read" => path2,
                        "create" => path2,
                        "update" => path2,
                        "delete" => path2},
                        "uuid" => tube_uuids_2[0],
                        "location" => nil,
                        "type" => tube_type,
                        "max_volume" => tube_max_volume,
                        "aliquots" => get_aliquot_array(sample_uuids_2[0])}
            }
          }
          let(:target2_tubes) {
            path1 = "http://example.org/#{tube_uuids_1[1]}"
            path2 = "http://example.org/#{tube_uuids_2[1]}"
            {
              target_locations_rack2[1] => {"actions" =>
                       {"read" => path2,
                        "create" => path2,
                        "update" => path2,
                        "delete" => path2},
                        "uuid" => tube_uuids_2[1],
                        "location" => nil,
                        "type" => tube_type,
                        "max_volume" => tube_max_volume,
                        "aliquots" => get_aliquot_array(sample_uuids_2[1])},
              target_locations_rack2[0] => {"actions" =>
                       {"read" => path1,
                        "create" => path1,
                        "update" => path1,
                        "delete" => path1},
                        "uuid" => tube_uuids_1[1],
                        "location" => nil,
                        "type" => tube_type,
                        "max_volume" => tube_max_volume,
                        "aliquots" => get_aliquot_array(sample_uuids_1[1])}
            }
          }

          let(:expected_json) {
            target1_url = "http://example.org/#{target_rack1_uuid}"
            target2_url = "http://example.org/#{target_rack2_uuid}"
            {
              :tube_rack_move => {
                :actions => {},
                :user => "user@example.com",
                :application => "application_id",
                :result => [
                  {"tube_rack" => {
                    "actions" => {
                      "read" => target1_url,
                      "create" => target1_url,
                      "update" => target1_url,
                      "delete" => target1_url,
                    },
                    "uuid" => target_rack1_uuid,
                    "number_of_rows" => number_of_rows,
                    "number_of_columns" => number_of_columns,
                    "location" => nil,
                    "tubes" => target1_tubes}
                  },
                  {"tube_rack" => {
                    "actions" => {
                      "read" => target2_url,
                      "create" => target2_url,
                      "update" => target2_url,
                      "delete" => target2_url,
                    },
                    "uuid" => target_rack2_uuid,
                    "number_of_rows" => number_of_rows,
                    "number_of_columns" => number_of_columns,
                    "location" => nil,
                    "tubes" => target2_tubes}
                  }
                ],
                :moves => moves
              }
            }
          }

          it_behaves_like "a valid core action"
        end
      end

    end
  end
end

