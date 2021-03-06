require "requests/apiary/15_fluidigm_resource/spec_helper"
describe "move_snp_assays_in_a_fluidigm", :fluidigm => true do
  include_context "use core context service"
  it "move_snp_assays_in_a_fluidigm" do
    allele_x = Lims::LaboratoryApp::Laboratory::Allele::A
    allele_y = Lims::LaboratoryApp::Laboratory::Allele::G
    snp_assay1 = Lims::LaboratoryApp::Laboratory::SnpAssay.new(:name => 'snp_assay 1', :allele_x => allele_x, :allele_y => allele_y)
    snp_assay2 = Lims::LaboratoryApp::Laboratory::SnpAssay.new(:name => 'snp_assay 2', :allele_x => allele_x, :allele_y => allele_y)
    snp_assay3 = Lims::LaboratoryApp::Laboratory::SnpAssay.new(:name => 'snp_assay 3', :allele_x => allele_x, :allele_y => allele_y)
    snp_assay4 = Lims::LaboratoryApp::Laboratory::SnpAssay.new(:name => 'snp_assay 4', :allele_x => allele_x, :allele_y => allele_y)
    
    fluidigm = Lims::LaboratoryApp::Laboratory::Fluidigm.new(:number_of_rows => 16, :number_of_columns => 12)
    fluidigm["S1"] << Lims::LaboratoryApp::Laboratory::Aliquot.new(:quantity => 10, :snp_assay => snp_assay1)
    fluidigm["S2"] << Lims::LaboratoryApp::Laboratory::Aliquot.new(:quantity => 10, :snp_assay => snp_assay2)
    fluidigm["S3"] << Lims::LaboratoryApp::Laboratory::Aliquot.new(:quantity => 10, :snp_assay => snp_assay3)
    fluidigm["S4"] << Lims::LaboratoryApp::Laboratory::Aliquot.new(:quantity => 10, :snp_assay => snp_assay4)
    
    save_with_uuid({
      snp_assay1 => [1,2,3,0,1], snp_assay2 => [1,2,3,0,2], snp_assay3 => [1,2,3,0,3], snp_assay4 => [1,2,3,0,4], 
      fluidigm => [1,2,3,2,1]
    })

    header('Content-Type', 'application/json')
    header('Accept', 'application/json')

    response = post "/actions/move_snp_assays", <<-EOD
    {
    "move_snp_assays": {
        "parameters": [
            {
                "resource_uuid": "11111111-2222-3333-2222-111111111111",
                "swaps": {
                    "11111111-2222-3333-0000-111111111111": "11111111-2222-3333-0000-444444444444",
                    "11111111-2222-3333-0000-222222222222": "11111111-2222-3333-0000-333333333333",
                    "11111111-2222-3333-0000-333333333333": "11111111-2222-3333-0000-222222222222",
                    "11111111-2222-3333-0000-444444444444": "11111111-2222-3333-0000-111111111111"
                }
            }
        ]
    }
}
    EOD
    response.should match_json_response(200, <<-EOD) 
    {
    "move_snp_assays": {
        "actions": {
        },
        "user": "user@example.com",
        "application": "application_id",
        "result": [
            {
                "fluidigm": {
                    "actions": {
                        "read": "http://example.org/11111111-2222-3333-2222-111111111111",
                        "create": "http://example.org/11111111-2222-3333-2222-111111111111",
                        "update": "http://example.org/11111111-2222-3333-2222-111111111111",
                        "delete": "http://example.org/11111111-2222-3333-2222-111111111111"
                    },
                    "uuid": "11111111-2222-3333-2222-111111111111",
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
                            {
                                "snp_assay": {
                                    "actions": {
                                        "read": "http://example.org/11111111-2222-3333-0000-444444444444",
                                        "create": "http://example.org/11111111-2222-3333-0000-444444444444",
                                        "update": "http://example.org/11111111-2222-3333-0000-444444444444",
                                        "delete": "http://example.org/11111111-2222-3333-0000-444444444444"
                                    },
                                    "uuid": "11111111-2222-3333-0000-444444444444",
                                    "name": "snp_assay 4",
                                    "allele_x": "A",
                                    "allele_y": "G"
                                },
                                "quantity": 10,
                                "unit": "mole"
                            }
                        ],
                        "S2": [
                            {
                                "snp_assay": {
                                    "actions": {
                                        "read": "http://example.org/11111111-2222-3333-0000-333333333333",
                                        "create": "http://example.org/11111111-2222-3333-0000-333333333333",
                                        "update": "http://example.org/11111111-2222-3333-0000-333333333333",
                                        "delete": "http://example.org/11111111-2222-3333-0000-333333333333"
                                    },
                                    "uuid": "11111111-2222-3333-0000-333333333333",
                                    "name": "snp_assay 3",
                                    "allele_x": "A",
                                    "allele_y": "G"
                                },
                                "quantity": 10,
                                "unit": "mole"
                            }
                        ],
                        "S3": [
                            {
                                "snp_assay": {
                                    "actions": {
                                        "read": "http://example.org/11111111-2222-3333-0000-222222222222",
                                        "create": "http://example.org/11111111-2222-3333-0000-222222222222",
                                        "update": "http://example.org/11111111-2222-3333-0000-222222222222",
                                        "delete": "http://example.org/11111111-2222-3333-0000-222222222222"
                                    },
                                    "uuid": "11111111-2222-3333-0000-222222222222",
                                    "name": "snp_assay 2",
                                    "allele_x": "A",
                                    "allele_y": "G"
                                },
                                "quantity": 10,
                                "unit": "mole"
                            }
                        ],
                        "S4": [
                            {
                                "snp_assay": {
                                    "actions": {
                                        "read": "http://example.org/11111111-2222-3333-0000-111111111111",
                                        "create": "http://example.org/11111111-2222-3333-0000-111111111111",
                                        "update": "http://example.org/11111111-2222-3333-0000-111111111111",
                                        "delete": "http://example.org/11111111-2222-3333-0000-111111111111"
                                    },
                                    "uuid": "11111111-2222-3333-0000-111111111111",
                                    "name": "snp_assay 1",
                                    "allele_x": "A",
                                    "allele_y": "G"
                                },
                                "quantity": 10,
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
        ],
        "parameters": [
            {
                "resource_uuid": "11111111-2222-3333-2222-111111111111",
                "swaps": {
                    "11111111-2222-3333-0000-111111111111": "11111111-2222-3333-0000-444444444444",
                    "11111111-2222-3333-0000-222222222222": "11111111-2222-3333-0000-333333333333",
                    "11111111-2222-3333-0000-333333333333": "11111111-2222-3333-0000-222222222222",
                    "11111111-2222-3333-0000-444444444444": "11111111-2222-3333-0000-111111111111"
                }
            }
        ]
    }
}
    EOD

  end
end
