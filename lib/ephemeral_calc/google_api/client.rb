require 'json'
require 'uri'
require 'net/http'
require 'base64'

module EphemeralCalc
  module GoogleAPI
    class Client

      PROXIMITY_BEACON_ROOT = "https://proximitybeacon.googleapis.com/v1beta1/"
      EIDPARAMS_URI = URI(PROXIMITY_BEACON_ROOT + "eidparams")
      BEACON_REGISTER_URI = URI("https://proximitybeacon.googleapis.com/v1beta1/beacons:register")

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

    end
  end
end
