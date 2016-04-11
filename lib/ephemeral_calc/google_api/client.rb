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
        http_opts = {use_ssl: true}
        response = Net::HTTP.start(EIDPARAMS_URI.host, EIDPARAMS_URI.port, http_opts) do |http|
          request = Net::HTTP::Get.new EIDPARAMS_URI.request_uri
          request.add_field "Authorization", "Bearer #{credentials.access_token}"
          request.add_field "Accept", "application/json"
          http.request request
        end
        if response.code.to_i == 200
          return JSON.parse(response.body)
        else
          raise RuntimeError, "Error #{response.code} (#{response.msg}) - #{EIDPARAMS_URI}\n#{response.body}"
        end
      end


      def register_eid(beacon_public_key, rotation_exp, initial_eid, initial_clock, uid_bytes)
        service_public_key_base64 = get_eidparams["serviceEcdhPublicKey"]
        http_opts = {use_ssl: true}
        response = Net::HTTP.start(BEACON_REGISTER_URI.host, BEACON_REGISTER_URI.port, http_opts) do |http|
          request = Net::HTTP::Post.new BEACON_REGISTER_URI.request_uri
          request.add_field "Authorization", "Bearer #{credentials.access_token}"
          request.add_field "Content-Type", "application/json"
          request.add_field "Accept", "application/json"
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
          http.request request
        end
        if response.code.to_i == 200
          return JSON.parse(response.body)
        else
          raise RuntimeError, "Error #{response.code} (#{response.msg}) - #{BEACON_REGISTER_URI}\n#{response.body}"
        end
      end

    end
  end
end
