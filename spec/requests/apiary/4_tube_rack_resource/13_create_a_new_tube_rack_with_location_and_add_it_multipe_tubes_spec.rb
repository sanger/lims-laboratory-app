require "requests/apiary/4_tube_rack_resource/spec_helper"
describe "create_a_new_tube_rack_with_location_and_add_it_multipe_tubes", :tube_rack => true do
  include_context "use core context service"
  it "create_a_new_tube_rack_with_location_and_add_it_multipe_tubes" do
  # **Create a new tube rack and add it multiple tubes.**
  # 
  # * `number_of_rows` number of rows in the rack
  # * `number_of_columns` number of columns in the rack
  # * `tubes` map tubes identified by their uuids to rack locations
    sample1 = Lims::LaboratoryApp::Laboratory::Sample.new(:name => 'sample 1')
    sample2 = Lims::LaboratoryApp::Laboratory::Sample.new(:name => 'sample 2')
    tube1 = Lims::LaboratoryApp::Laboratory::Tube.new << Lims::LaboratoryApp::Laboratory::Aliquot.new(:quantity => 5, :type => "NA", :sample => sample1)
    tube2 = Lims::LaboratoryApp::Laboratory::Tube.new << Lims::LaboratoryApp::Laboratory::Aliquot.new(:quantity => 10, :type => "RNA", :sample => sample2)
    
    save_with_uuid sample1 => [1,2,3,0,0], sample2 => [1,2,3,0,1], tube1 => [1,2,3,4,1], tube2 => [1,2,3,4,2]
    set_uuid_start(1,2,3,4,7)

    header('Content-Type', 'application/json')
    header('Accept', 'application/json')

    response = post "/tube_racks", <<-EOD
    {
    "tube_rack": {
        "number_of_rows": 8,
        "number_of_columns": 12,
        "tubes": {
            "A1": "11111111-2222-3333-4444-111111111111",
            "E5": "11111111-2222-3333-4444-222222222222"
        },
        "location": {
            "name": "ABC Hospital",
            "address": "CB11 2TY TubeCity 123 Sample Way"
        }
    }
}
    EOD
    response.should match_json_response(200, <<-EOD) 
    {
    "tube_rack": {
        "actions": {
            "create": "http://example.org/11111111-2222-3333-4444-777777777777",
            "read": "http://example.org/11111111-2222-3333-4444-777777777777",
            "update": "http://example.org/11111111-2222-3333-4444-777777777777",
            "delete": "http://example.org/11111111-2222-3333-4444-777777777777"
        },
        "uuid": "11111111-2222-3333-4444-777777777777",
        "number_of_rows": 8,
        "number_of_columns": 12,
        "location": {
            "actions": {
                "read": "http://example.org/11111111-2222-3333-4444-999999999999",
                "create": "http://example.org/11111111-2222-3333-4444-999999999999",
                "update": "http://example.org/11111111-2222-3333-4444-999999999999",
                "delete": "http://example.org/11111111-2222-3333-4444-999999999999"
            },
            "uuid": "11111111-2222-3333-4444-999999999999",
            "name": "ABC Hospital",
            "address": "CB11 2TY TubeCity 123 Sample Way",
            "internal": true
        },
        "tubes": {
            "A1": {
                "actions": {
                    "create": "http://example.org/11111111-2222-3333-4444-111111111111",
                    "read": "http://example.org/11111111-2222-3333-4444-111111111111",
                    "update": "http://example.org/11111111-2222-3333-4444-111111111111",
                    "delete": "http://example.org/11111111-2222-3333-4444-111111111111"
                },
                "uuid": "11111111-2222-3333-4444-111111111111",
                "location": null,
                "type": null,
                "max_volume": null,
                "aliquots": [
                    {
                        "sample": {
                            "actions": {
                                "read": "http://example.org/11111111-2222-3333-0000-000000000000",
                                "create": "http://example.org/11111111-2222-3333-0000-000000000000",
                                "update": "http://example.org/11111111-2222-3333-0000-000000000000",
                                "delete": "http://example.org/11111111-2222-3333-0000-000000000000"
                            },
                            "uuid": "11111111-2222-3333-0000-000000000000",
                            "name": "sample 1"
                        },
                        "quantity": 5,
                        "type": "NA",
                        "unit": "mole"
                    }
                ]
            },
            "E5": {
                "actions": {
                    "read": "http://example.org/11111111-2222-3333-4444-222222222222",
                    "create": "http://example.org/11111111-2222-3333-4444-222222222222",
                    "update": "http://example.org/11111111-2222-3333-4444-222222222222",
                    "delete": "http://example.org/11111111-2222-3333-4444-222222222222"
                },
                "uuid": "11111111-2222-3333-4444-222222222222",
                "location": null,
                "type": null,
                "max_volume": null,
                "aliquots": [
                    {
                        "sample": {
                            "actions": {
                                "read": "http://example.org/11111111-2222-3333-0000-111111111111",
                                "create": "http://example.org/11111111-2222-3333-0000-111111111111",
                                "update": "http://example.org/11111111-2222-3333-0000-111111111111",
                                "delete": "http://example.org/11111111-2222-3333-0000-111111111111"
                            },
                            "uuid": "11111111-2222-3333-0000-111111111111",
                            "name": "sample 2"
                        },
                        "quantity": 10,
                        "type": "RNA",
                        "unit": "mole"
                    }
                ]
            }
        }
    }
}
    EOD

  end
end
