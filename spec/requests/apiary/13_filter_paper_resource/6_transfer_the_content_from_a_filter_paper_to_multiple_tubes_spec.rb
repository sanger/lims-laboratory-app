require "requests/apiary/13_filter_paper_resource/spec_helper"
describe "transfer_the_content_from_a_filter_paper_to_multiple_tubes", :filter_paper => true do
  include_context "use core context service"
  it "transfer_the_content_from_a_filter_paper_to_multiple_tubes" do
  # **Transfer the content from the location(s) of filter paper to 1 or multiple tubes**.
  # 
  # This action transfers the content of 1 or more location(s) of a Filter Paper
  # to to 1 or more tube(s).
  # 
  # * `source_uuid` uuid of the source Filter Paper
  # * `transfers` it is an array, contains the element(s) of the transfer
  # 
  # The array contaions the following parameters:
  # 
  # * `source_location` is the location on the Filter Paper (like "A1") from transfer the aliquots
  # * `target_uuid` uuid of the target tube
  # 
  # The example below shows how to make a transfer from "A1" and "A2" Location 
  # of a Filter Paper to multiple tubes:
  # 
  # * from filter paper `11111111-2222-3333-4444-444444444444`
  # "A1" Location to tube `11111111-2222-3333-4444-666666666666` and 
  # "A2" Location to tube `11111111-2222-3333-4444-777777777777`
    sample1 = Lims::LaboratoryApp::Laboratory::Sample.new(:name => 'sample 1')
    sample2 = Lims::LaboratoryApp::Laboratory::Sample.new(:name => 'sample 2')
    
    filter_paper = Lims::LaboratoryApp::Laboratory::FilterPaper.new(
        :number_of_rows =>      2,
        :number_of_columns =>   2)
    filter_paper["A1"] << Lims::LaboratoryApp::Laboratory::Aliquot.new(:quantity => 100, :type => "sample", :sample => sample1)
    filter_paper["A2"] << Lims::LaboratoryApp::Laboratory::Aliquot.new(:quantity => 100, :type => "sample", :sample => sample2)
    
    tube1 = Lims::LaboratoryApp::Laboratory::Tube.new
    tube2 = Lims::LaboratoryApp::Laboratory::Tube.new
    
    save_with_uuid filter_paper => [1,2,3,4,4], sample1 => [1,2,3,0,0], sample2 => [1,2,3,0,0], tube1 => [1,2,3,4,6], tube2 => [1,2,3,4,7]

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/actions/transfer_locations_to_tubes", <<-EOD
    {
    "transfer_locations_to_tubes": {
        "source_uuid": "11111111-2222-3333-4444-444444444444",
        "transfers": [
            {
                "source_location": "A1",
                "target_uuid": "11111111-2222-3333-4444-666666666666"
            },
            {
                "source_location": "A2",
                "target_uuid": "11111111-2222-3333-4444-777777777777"
            }
        ]
    }
}
    EOD
    response.status.should == 200
    response.body.should match_json <<-EOD
    {
    "transfer_locations_to_tubes": {
        "actions": {
        },
        "user": "user",
        "application": "application",
        "result": {
            "targets": [
                {
                    "tube": {
                        "actions": {
                            "read": "http://example.org/11111111-2222-3333-4444-666666666666",
                            "create": "http://example.org/11111111-2222-3333-4444-666666666666",
                            "update": "http://example.org/11111111-2222-3333-4444-666666666666",
                            "delete": "http://example.org/11111111-2222-3333-4444-666666666666"
                        },
                        "uuid": "11111111-2222-3333-4444-666666666666",
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
                                "quantity": 100,
                                "type": "sample",
                                "unit": "mole"
                            }
                        ]
                    }
                },
                {
                    "tube": {
                        "actions": {
                            "read": "http://example.org/11111111-2222-3333-4444-777777777777",
                            "create": "http://example.org/11111111-2222-3333-4444-777777777777",
                            "update": "http://example.org/11111111-2222-3333-4444-777777777777",
                            "delete": "http://example.org/11111111-2222-3333-4444-777777777777"
                        },
                        "uuid": "11111111-2222-3333-4444-777777777777",
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
                                    "name": "sample 2"
                                },
                                "quantity": 100,
                                "type": "sample",
                                "unit": "mole"
                            }
                        ]
                    }
                }
            ]
        },
        "source_uuid": "11111111-2222-3333-4444-444444444444",
        "transfers": [
            {
                "source_location": "A1",
                "target_uuid": "11111111-2222-3333-4444-666666666666"
            },
            {
                "source_location": "A2",
                "target_uuid": "11111111-2222-3333-4444-777777777777"
            }
        ]
    }
}
    EOD

  end
end