require "requests/apiary/8_order_resource/spec_helper"
describe "assign_an_item_to_a_batch", :order => true do
  include_context "use core context service"
  it "assign_an_item_to_a_batch" do
  # **Assign an item to a batch**
  # 
  # This example can be combined with more complete order update using the above update example.
  # 
  # * `items` can take a `batch_uuid` attribute to assign an item to a batch
  # 
  # The example below update an order and assign the item `11111111-2222-3333-4444-666666666666` to the batch 
  # `11111111-2222-3333-4444-777777777777`. Note that an item can be assigned to a batch only through 
  # an update order action.
    study = Lims::LaboratoryApp::Organization::Study.new
    user = Lims::LaboratoryApp::Organization::User.new(:email => 'user@example.com')
    order = Lims::LaboratoryApp::Organization::Order.new(:creator => user, :study => study, :pipeline => "P1", :cost_code => "cost code")
    tube = Lims::LaboratoryApp::Laboratory::Tube.new
    batch = Lims::LaboratoryApp::Organization::Batch.new(:process => "manual extraction")
    
    save_with_uuid study => [1,1,1,1,1], user => [1,1,1,1,0], order => [1,2,3,4,5], tube => [1,2,3,4,6], batch => [1,2,3,4,7]

    header('Content-Type', 'application/json')
    header('Accept', 'application/json')

    response = put "/11111111-2222-3333-4444-555555555555", <<-EOD
    {
    "items": {
        "role1": {
            "11111111-2222-3333-4444-666666666666": {
                "batch_uuid": "11111111-2222-3333-4444-777777777777"
            }
        }
    }
}
    EOD
    response.should match_json_response(200, <<-EOD) 
    {
    "order": {
        "actions": {
            "read": "http://example.org/11111111-2222-3333-4444-555555555555",
            "create": "http://example.org/11111111-2222-3333-4444-555555555555",
            "update": "http://example.org/11111111-2222-3333-4444-555555555555",
            "delete": "http://example.org/11111111-2222-3333-4444-555555555555"
        },
        "uuid": "11111111-2222-3333-4444-555555555555",
        "pipeline": "P1",
        "status": "draft",
        "parameters": {
        },
        "state": {
        },
        "cost_code": "cost code",
        "creator": {
            "actions": {
                "read": "http://example.org/11111111-1111-1111-1111-000000000000",
                "create": "http://example.org/11111111-1111-1111-1111-000000000000",
                "update": "http://example.org/11111111-1111-1111-1111-000000000000",
                "delete": "http://example.org/11111111-1111-1111-1111-000000000000"
            },
            "uuid": "11111111-1111-1111-1111-000000000000",
            "email": "user@example.com"
        },
        "study": {
            "actions": {
                "read": "http://example.org/11111111-1111-1111-1111-111111111111",
                "create": "http://example.org/11111111-1111-1111-1111-111111111111",
                "update": "http://example.org/11111111-1111-1111-1111-111111111111",
                "delete": "http://example.org/11111111-1111-1111-1111-111111111111"
            },
            "uuid": "11111111-1111-1111-1111-111111111111"
        },
        "items": {
            "role1": [
                {
                    "uuid": "11111111-2222-3333-4444-666666666666",
                    "status": "pending",
                    "batch": {
                        "actions": {
                            "read": "http://example.org/11111111-2222-3333-4444-777777777777",
                            "create": "http://example.org/11111111-2222-3333-4444-777777777777",
                            "update": "http://example.org/11111111-2222-3333-4444-777777777777",
                            "delete": "http://example.org/11111111-2222-3333-4444-777777777777"
                        },
                        "uuid": "11111111-2222-3333-4444-777777777777",
                        "process": "manual extraction",
                        "kit": null
                    }
                }
            ]
        }
    }
}
    EOD

  end
end
