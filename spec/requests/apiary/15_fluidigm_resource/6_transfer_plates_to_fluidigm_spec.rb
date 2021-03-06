require "requests/apiary/15_fluidigm_resource/spec_helper"
describe "transfer_plates_to_fluidigm", :fluidigm => true do
  include_context "use core context service"
  it "transfer_plates_to_fluidigm" do
  # **Transfer plates to fluidigm action.**
  # 
  # This action transfers the given fraction of aliquot from plate-like asset(s)
  # to a fluidigm asset and it changes the aliquot type to the given one.
  # 
  # The action takes an array, which contains transfer elements.
  # 
  # * `source_uuid` uuid of the source asset (plate)
  # * `source_location` is the well location (like "A1") from transfer the aliquots
  # * `target_uuid` uuid of the target asset (fluidigm)
  # * `target_location` is the well (like "S1") to transfer the aliquots.
  # * `fractionmount` Amount is an amount of an aliquot to transfer.
  # Fraction is the fraction of an aliquot to transfer.
  # You should give the fraction OR the amount of the transfer, not both of them.
  # * `aliquot_type` set a new type for all aliquots in the target plate-like asset
    sample1 = Lims::LaboratoryApp::Laboratory::Sample.new(:name => 'sample for A1')
    source_plate = Lims::LaboratoryApp::Laboratory::Plate.new(:number_of_rows => 8,
                                    :number_of_columns => 12,
                                    :type => "source plate type")
    source_plate["A1"] << Lims::LaboratoryApp::Laboratory::Aliquot.new(:quantity => 100, :type => "sample", :sample => sample1)
    
    sample2 = Lims::LaboratoryApp::Laboratory::Sample.new(:name => 'sample for C3')
    source_plate["C3"] << Lims::LaboratoryApp::Laboratory::Aliquot.new(:quantity => 100, :type => "sample", :sample => sample2)
    
    target_fluidigm = Lims::LaboratoryApp::Laboratory::Fluidigm.new(:number_of_rows => 16,
                                    :number_of_columns => 12)
    
    save_with_uuid sample1 => [1,2,3,4,5], sample2 => [1,2,3,4,6], source_plate => [1,2,3,1,0], target_fluidigm => [1,2,3,1,2]

    header('Content-Type', 'application/json')
    header('Accept', 'application/json')

    response = post "/actions/transfer_plates_to_fluidigm", <<-EOD
    {
    "transfer_plates_to_fluidigm": {
        "transfers": [
            {
                "source_uuid": "11111111-2222-3333-1111-000000000000",
                "source_location": "A1",
                "target_uuid": "11111111-2222-3333-1111-222222222222",
                "target_location": "S2",
                "fraction": 0.4,
                "aliquot_type": "DNA"
            },
            {
                "source_uuid": "11111111-2222-3333-1111-000000000000",
                "source_location": "C3",
                "target_uuid": "11111111-2222-3333-1111-222222222222",
                "target_location": "S4",
                "fraction": 0.4,
                "aliquot_type": "RNA"
            }
        ]
    }
}
    EOD
    response.should match_json_response(200, <<-EOD) 
    {
    "transfer_plates_to_fluidigm": {
        "actions": {
        },
        "user": "user@example.com",
        "application": "application_id",
        "result": {
            "sources": [
                {
                    "plate": {
                        "actions": {
                            "read": "http://example.org/11111111-2222-3333-1111-000000000000",
                            "create": "http://example.org/11111111-2222-3333-1111-000000000000",
                            "update": "http://example.org/11111111-2222-3333-1111-000000000000",
                            "delete": "http://example.org/11111111-2222-3333-1111-000000000000"
                        },
                        "uuid": "11111111-2222-3333-1111-000000000000",
                        "type": "source plate type",
                        "number_of_rows": 8,
                        "number_of_columns": 12,
                        "location": null,
                        "wells": {
                            "A1": [
                                {
                                    "sample": {
                                        "actions": {
                                            "read": "http://example.org/11111111-2222-3333-4444-555555555555",
                                            "create": "http://example.org/11111111-2222-3333-4444-555555555555",
                                            "update": "http://example.org/11111111-2222-3333-4444-555555555555",
                                            "delete": "http://example.org/11111111-2222-3333-4444-555555555555"
                                        },
                                        "uuid": "11111111-2222-3333-4444-555555555555",
                                        "name": "sample for A1"
                                    },
                                    "quantity": 100,
                                    "type": "sample",
                                    "unit": "mole"
                                }
                            ],
                            "A2": [

                            ],
                            "A3": [

                            ],
                            "A4": [

                            ],
                            "A5": [

                            ],
                            "A6": [

                            ],
                            "A7": [

                            ],
                            "A8": [

                            ],
                            "A9": [

                            ],
                            "A10": [

                            ],
                            "A11": [

                            ],
                            "A12": [

                            ],
                            "B1": [

                            ],
                            "B2": [

                            ],
                            "B3": [

                            ],
                            "B4": [

                            ],
                            "B5": [

                            ],
                            "B6": [

                            ],
                            "B7": [

                            ],
                            "B8": [

                            ],
                            "B9": [

                            ],
                            "B10": [

                            ],
                            "B11": [

                            ],
                            "B12": [

                            ],
                            "C1": [

                            ],
                            "C2": [

                            ],
                            "C3": [
                                {
                                    "sample": {
                                        "actions": {
                                            "read": "http://example.org/11111111-2222-3333-4444-666666666666",
                                            "create": "http://example.org/11111111-2222-3333-4444-666666666666",
                                            "update": "http://example.org/11111111-2222-3333-4444-666666666666",
                                            "delete": "http://example.org/11111111-2222-3333-4444-666666666666"
                                        },
                                        "uuid": "11111111-2222-3333-4444-666666666666",
                                        "name": "sample for C3"
                                    },
                                    "quantity": 100,
                                    "type": "sample",
                                    "unit": "mole"
                                }
                            ],
                            "C4": [

                            ],
                            "C5": [

                            ],
                            "C6": [

                            ],
                            "C7": [

                            ],
                            "C8": [

                            ],
                            "C9": [

                            ],
                            "C10": [

                            ],
                            "C11": [

                            ],
                            "C12": [

                            ],
                            "D1": [

                            ],
                            "D2": [

                            ],
                            "D3": [

                            ],
                            "D4": [

                            ],
                            "D5": [

                            ],
                            "D6": [

                            ],
                            "D7": [

                            ],
                            "D8": [

                            ],
                            "D9": [

                            ],
                            "D10": [

                            ],
                            "D11": [

                            ],
                            "D12": [

                            ],
                            "E1": [

                            ],
                            "E2": [

                            ],
                            "E3": [

                            ],
                            "E4": [

                            ],
                            "E5": [

                            ],
                            "E6": [

                            ],
                            "E7": [

                            ],
                            "E8": [

                            ],
                            "E9": [

                            ],
                            "E10": [

                            ],
                            "E11": [

                            ],
                            "E12": [

                            ],
                            "F1": [

                            ],
                            "F2": [

                            ],
                            "F3": [

                            ],
                            "F4": [

                            ],
                            "F5": [

                            ],
                            "F6": [

                            ],
                            "F7": [

                            ],
                            "F8": [

                            ],
                            "F9": [

                            ],
                            "F10": [

                            ],
                            "F11": [

                            ],
                            "F12": [

                            ],
                            "G1": [

                            ],
                            "G2": [

                            ],
                            "G3": [

                            ],
                            "G4": [

                            ],
                            "G5": [

                            ],
                            "G6": [

                            ],
                            "G7": [

                            ],
                            "G8": [

                            ],
                            "G9": [

                            ],
                            "G10": [

                            ],
                            "G11": [

                            ],
                            "G12": [

                            ],
                            "H1": [

                            ],
                            "H2": [

                            ],
                            "H3": [

                            ],
                            "H4": [

                            ],
                            "H5": [

                            ],
                            "H6": [

                            ],
                            "H7": [

                            ],
                            "H8": [

                            ],
                            "H9": [

                            ],
                            "H10": [

                            ],
                            "H11": [

                            ],
                            "H12": [

                            ]
                        }
                    }
                }
            ],
            "targets": [
                {
                    "fluidigm": {
                        "actions": {
                            "read": "http://example.org/11111111-2222-3333-1111-222222222222",
                            "create": "http://example.org/11111111-2222-3333-1111-222222222222",
                            "update": "http://example.org/11111111-2222-3333-1111-222222222222",
                            "delete": "http://example.org/11111111-2222-3333-1111-222222222222"
                        },
                        "uuid": "11111111-2222-3333-1111-222222222222",
                        "number_of_rows": 16,
                        "number_of_columns": 12,
                        "location": null,
                        "fluidigm_wells": {
                            "A1": [

                            ],
                            "A2": [

                            ],
                            "A3": [

                            ],
                            "A4": [

                            ],
                            "A5": [

                            ],
                            "A6": [

                            ],
                            "S1": [

                            ],
                            "S2": [
                                {
                                    "sample": {
                                        "actions": {
                                            "read": "http://example.org/11111111-2222-3333-4444-555555555555",
                                            "create": "http://example.org/11111111-2222-3333-4444-555555555555",
                                            "update": "http://example.org/11111111-2222-3333-4444-555555555555",
                                            "delete": "http://example.org/11111111-2222-3333-4444-555555555555"
                                        },
                                        "uuid": "11111111-2222-3333-4444-555555555555",
                                        "name": "sample for A1"
                                    },
                                    "type": "DNA",
                                    "unit": "mole"
                                }
                            ],
                            "S3": [

                            ],
                            "S4": [
                                {
                                    "sample": {
                                        "actions": {
                                            "read": "http://example.org/11111111-2222-3333-4444-666666666666",
                                            "create": "http://example.org/11111111-2222-3333-4444-666666666666",
                                            "update": "http://example.org/11111111-2222-3333-4444-666666666666",
                                            "delete": "http://example.org/11111111-2222-3333-4444-666666666666"
                                        },
                                        "uuid": "11111111-2222-3333-4444-666666666666",
                                        "name": "sample for C3"
                                    },
                                    "type": "RNA",
                                    "unit": "mole"
                                }
                            ],
                            "S5": [

                            ],
                            "S6": [

                            ],
                            "A7": [

                            ],
                            "A8": [

                            ],
                            "A9": [

                            ],
                            "A10": [

                            ],
                            "A11": [

                            ],
                            "A12": [

                            ],
                            "S7": [

                            ],
                            "S8": [

                            ],
                            "S9": [

                            ],
                            "S10": [

                            ],
                            "S11": [

                            ],
                            "S12": [

                            ],
                            "A13": [

                            ],
                            "A14": [

                            ],
                            "A15": [

                            ],
                            "A16": [

                            ],
                            "A17": [

                            ],
                            "A18": [

                            ],
                            "S13": [

                            ],
                            "S14": [

                            ],
                            "S15": [

                            ],
                            "S16": [

                            ],
                            "S17": [

                            ],
                            "S18": [

                            ],
                            "A19": [

                            ],
                            "A20": [

                            ],
                            "A21": [

                            ],
                            "A22": [

                            ],
                            "A23": [

                            ],
                            "A24": [

                            ],
                            "S19": [

                            ],
                            "S20": [

                            ],
                            "S21": [

                            ],
                            "S22": [

                            ],
                            "S23": [

                            ],
                            "S24": [

                            ],
                            "A25": [

                            ],
                            "A26": [

                            ],
                            "A27": [

                            ],
                            "A28": [

                            ],
                            "A29": [

                            ],
                            "A30": [

                            ],
                            "S25": [

                            ],
                            "S26": [

                            ],
                            "S27": [

                            ],
                            "S28": [

                            ],
                            "S29": [

                            ],
                            "S30": [

                            ],
                            "A31": [

                            ],
                            "A32": [

                            ],
                            "A33": [

                            ],
                            "A34": [

                            ],
                            "A35": [

                            ],
                            "A36": [

                            ],
                            "S31": [

                            ],
                            "S32": [

                            ],
                            "S33": [

                            ],
                            "S34": [

                            ],
                            "S35": [

                            ],
                            "S36": [

                            ],
                            "A37": [

                            ],
                            "A38": [

                            ],
                            "A39": [

                            ],
                            "A40": [

                            ],
                            "A41": [

                            ],
                            "A42": [

                            ],
                            "S37": [

                            ],
                            "S38": [

                            ],
                            "S39": [

                            ],
                            "S40": [

                            ],
                            "S41": [

                            ],
                            "S42": [

                            ],
                            "A43": [

                            ],
                            "A44": [

                            ],
                            "A45": [

                            ],
                            "A46": [

                            ],
                            "A47": [

                            ],
                            "A48": [

                            ],
                            "S43": [

                            ],
                            "S44": [

                            ],
                            "S45": [

                            ],
                            "S46": [

                            ],
                            "S47": [

                            ],
                            "S48": [

                            ],
                            "A49": [

                            ],
                            "A50": [

                            ],
                            "A51": [

                            ],
                            "A52": [

                            ],
                            "A53": [

                            ],
                            "A54": [

                            ],
                            "S49": [

                            ],
                            "S50": [

                            ],
                            "S51": [

                            ],
                            "S52": [

                            ],
                            "S53": [

                            ],
                            "S54": [

                            ],
                            "A55": [

                            ],
                            "A56": [

                            ],
                            "A57": [

                            ],
                            "A58": [

                            ],
                            "A59": [

                            ],
                            "A60": [

                            ],
                            "S55": [

                            ],
                            "S56": [

                            ],
                            "S57": [

                            ],
                            "S58": [

                            ],
                            "S59": [

                            ],
                            "S60": [

                            ],
                            "A61": [

                            ],
                            "A62": [

                            ],
                            "A63": [

                            ],
                            "A64": [

                            ],
                            "A65": [

                            ],
                            "A66": [

                            ],
                            "S61": [

                            ],
                            "S62": [

                            ],
                            "S63": [

                            ],
                            "S64": [

                            ],
                            "S65": [

                            ],
                            "S66": [

                            ],
                            "A67": [

                            ],
                            "A68": [

                            ],
                            "A69": [

                            ],
                            "A70": [

                            ],
                            "A71": [

                            ],
                            "A72": [

                            ],
                            "S67": [

                            ],
                            "S68": [

                            ],
                            "S69": [

                            ],
                            "S70": [

                            ],
                            "S71": [

                            ],
                            "S72": [

                            ],
                            "A73": [

                            ],
                            "A74": [

                            ],
                            "A75": [

                            ],
                            "A76": [

                            ],
                            "A77": [

                            ],
                            "A78": [

                            ],
                            "S73": [

                            ],
                            "S74": [

                            ],
                            "S75": [

                            ],
                            "S76": [

                            ],
                            "S77": [

                            ],
                            "S78": [

                            ],
                            "A79": [

                            ],
                            "A80": [

                            ],
                            "A81": [

                            ],
                            "A82": [

                            ],
                            "A83": [

                            ],
                            "A84": [

                            ],
                            "S79": [

                            ],
                            "S80": [

                            ],
                            "S81": [

                            ],
                            "S82": [

                            ],
                            "S83": [

                            ],
                            "S84": [

                            ],
                            "A85": [

                            ],
                            "A86": [

                            ],
                            "A87": [

                            ],
                            "A88": [

                            ],
                            "A89": [

                            ],
                            "A90": [

                            ],
                            "S85": [

                            ],
                            "S86": [

                            ],
                            "S87": [

                            ],
                            "S88": [

                            ],
                            "S89": [

                            ],
                            "S90": [

                            ],
                            "A91": [

                            ],
                            "A92": [

                            ],
                            "A93": [

                            ],
                            "A94": [

                            ],
                            "A95": [

                            ],
                            "A96": [

                            ],
                            "S91": [

                            ],
                            "S92": [

                            ],
                            "S93": [

                            ],
                            "S94": [

                            ],
                            "S95": [

                            ],
                            "S96": [

                            ]
                        }
                    }
                }
            ]
        },
        "transfers": [
            {
                "source_uuid": "11111111-2222-3333-1111-000000000000",
                "source_location": "A1",
                "target_uuid": "11111111-2222-3333-1111-222222222222",
                "target_location": "S2",
                "fraction": 0.4,
                "aliquot_type": "DNA"
            },
            {
                "source_uuid": "11111111-2222-3333-1111-000000000000",
                "source_location": "C3",
                "target_uuid": "11111111-2222-3333-1111-222222222222",
                "target_location": "S4",
                "fraction": 0.4,
                "aliquot_type": "RNA"
            }
        ]
    }
}
    EOD

  end
end
