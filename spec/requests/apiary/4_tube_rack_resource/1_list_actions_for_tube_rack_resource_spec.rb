require "requests/apiary/4_tube_rack_resource/spec_helper"
describe "list_actions_for_tube_rack_resource", :tube_rack => true do
  include_context "use core context service"
  it "list_actions_for_tube_rack_resource" do
  # **List actions for tube rack resource.**
  # 
  # * `create` creates a new tube rack via HTTP POST request
  # * `read` currently returns the list of actions for a tube rack resource via HTTP GET request
  # * `first` lists the first tube rack resources in a page browsing system
  # * `last` lists the last tube rack resources in a page browsing system

    header('Content-Type', 'application/json')
    header('Accept', 'application/json')

    response = get "/tube_racks"
    response.should match_json_response(200, <<-EOD) 
    {
    "tube_racks": {
        "actions": {
            "create": "http://example.org/tube_racks",
            "read": "http://example.org/tube_racks",
            "first": "http://example.org/tube_racks/page=1",
            "last": "http://example.org/tube_racks/page=-1"
        }
    }
}
    EOD

  end
end
