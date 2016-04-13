require 'json'
require 'uri'
require 'net/http'
require 'base64'

module EphemeralCalc
  module GoogleAPI
    class Client

      PROXIMITY_BEACON_ROOT = "https://proximitybeacon.googleapis.com/v1beta1/"
      EIDPARAMS_URI = URI(PROXIMITY_BEACON_ROOT + "eidparams")
      BEACON_REGISTER_URI = URI(PROXIMITY_BEACON_ROOT + "beacons:register")

      attr_accessor :credentials

      def initialize(credentials = OAuth.new.get_credentials)
        self.credentials = credentials
      end

      def get_eidparams
        response = Request.get(EIDPARAMS_URI, credentials)
        # response = request(:get, EIDPARAMS_URI, credentials.access_token)
        return JSON.parse(response.body)
      end


      def register_eid(beacon_public_key, rotation_exp, initial_eid, initial_clock, uid_bytes)
        service_public_key_base64 = get_eidparams["serviceEcdhPublicKey"]
        response = Request.post(BEACON_REGISTER_URI, credentials) {|request|
          request.add_field "Content-Type", "application/json"
          request.body = {
            ephemeralIdRegistration: {
              beaconEcdhPublicKey: Base64.strict_encode64(beacon_public_key),
              serviceEcdhPublicKey: service_public_key_base64,
              rotationPeriodExponent: rotation_exp,
              initialClockValue: initial_clock,
              initialEid: Base64.strict_encode64(initial_eid)
            },
            advertisedId: {
              type: "EDDYSTONE",
              id: Base64.strict_encode64(uid_bytes)
            },
            status: "ACTIVE",
            description: "EphemeralCalc Registered EID"
          }.to_json
        }
        JSON.parse(response.body)
      end

      def get_resource(resource_name)
        uri = URI(PROXIMITY_BEACON_ROOT + resource_name)
        response = Request.get(uri, credentials)
        JSON.parse(response.body)
      end

      def getforobserved(eids, api_key = ENV["GOOGLE_API_KEY"])
        uri = URI("#{PROXIMITY_BEACON_ROOT}beaconinfo:getforobserved?key=#{api_key}")
        response = Request.post(uri) {|request|
          observations = Array(eids).map {|eid|
            {advertisedId: {type: "EDDYSTONE_EID", id: base64_eid(eid)}}
          }
          request.body = {
            observations: observations,
            namespacedTypes: "*",
          }.to_json
          request.add_field "Content-Type", "application/json"
        }
        JSON.parse(response.body)
      end

    private

      def base64_eid(eid)
        if eid.size == 16
          Base64.strict_encode64([eid].pack("H*"))
        else
          Base64.strict_encode64(eid)
        end
      end

    end
  end
end
