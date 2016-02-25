require 'spec_Helper'

module EphemeralCalc
  RSpec.describe GoogleResolver do
    let(:api_key) { "API_KEY_HERE" }
    let(:getforobserved_url) {
      "https://proximitybeacon.googleapis.com/v1beta1/beaconinfo:getforobserved?key=#{api_key}"
    }
    let(:resolvable_eid) { "0102030405060708" }
    let(:nonresolvable_eid) { "DEAD030405060708" }

    let(:beacon_response) {
      {"beaconName" => "BEACON1"}
    }

    def observations_for(eid)
      base64_eid = Base64.strict_encode64([eid].pack("H*"))
      "{\"observations\":[{\"advertisedId\":{\"type\":\"EDDYSTONE_EID\",\"id\":\"#{base64_eid}\"}}]}"
    end

    def stub_eid_request(eid, response)
      stub_request(:post, getforobserved_url).with(
        :body => observations_for(eid)
      ).to_return(:status => 200, :body => response.to_json, :headers => {})
    end


    it "calls Google's Proximity Beacon API getforobservered endpoint" do
      stub_eid_request(resolvable_eid, {beacons: [beacon_response]})

      response = GoogleResolver.resolve api_key, resolvable_eid
      expect(response).to eq(beacon_response)
    end

    it "returns nil if no beacons are returned" do
      stub_eid_request(nonresolvable_eid, {})
      response = GoogleResolver.resolve api_key, nonresolvable_eid
      expect(response).to be_nil
    end
  end
end
