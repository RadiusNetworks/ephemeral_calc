require 'base64'
require 'json'
require 'uri'
require 'net/http'

module EphemeralCalc
  class GoogleResolver

    GETFOROBSERVED_URI = URI("https://proximitybeacon.googleapis.com/v1beta1/beaconinfo:getforobserved")

    def self.resolve(api_key, eid)
      # TODO: figure out why SSL verification is failing, fix, and reenable!
      http_opts = {use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE}
      response = Net::HTTP.start(GETFOROBSERVED_URI.host, GETFOROBSERVED_URI.port, http_opts) do |http|
        request = Net::HTTP::Post.new "#{GETFOROBSERVED_URI.request_uri}?key=#{api_key}"
        request.body = observations(eid).to_json
        request.add_field "Content-Type", "application/json"
        request.add_field "Accepts", "application/json"
        http.request request
      end
      if response.code.to_i == 200
        json = JSON.parse(response.body)
        if json["beacons"]
          return json["beacons"][0]
        else
          return nil
        end
      else
        raise RuntimeError, "Error #{response.code} (#{response.msg}) - #{GETFOROBSERVED_URI}"
      end
    end

    private

    def self.observations(eids)
      observations = Array(eids).map {|eid| {advertisedId: {type: "EDDYSTONE_EID", id: base64(eid)}}}
      return {observations: observations}
    end

    def self.base64(eid)
      if eid.size == 16
        Base64.encode64([eid].pack("H*"))
      else
        Base64.encode64(eid)
      end
    end

  end
end
