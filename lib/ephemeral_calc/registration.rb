module EphemeralCalc
  class Registration

    DEFAULT_NAMESPACE = "e3dd811dd3bbe49e630a"
    DEFAULT_ROTATION_EXP = 12 # 2^12 = ~68 minutes

    attr_reader :description,
                :rotation_exp,
                :namespace,
                :instance,
                :beacon_private_key,
                :beacon_keypair,
                :beacon_time_zero,
                :beacon_name

    def initialize(name:,
                   rotation_exp: nil,
                   namespace: nil,
                   instance: nil,
                   beacon_private_key: nil)
      @description = name
      @rotation_exp = (rotation_exp || DEFAULT_ROTATION_EXP).to_i
      @namespace = namespace || DEFAULT_NAMESPACE
      @instance = instance || random_instance
      @beacon_private_key = beacon_private_key || EphemeralCalc::KeyPair.generate_private_key
      @beacon_keypair = EphemeralCalc::KeyPair.new(@beacon_private_key)
    end

    def api_client
      @api_client ||= ProximityBeacon::Client.new
    end

    def eid_params
      @eid_params ||= api_client.eidparams
    end

    def resolver_public_key
      Base64.decode64(eid_params["serviceEcdhPublicKey"])
    end

    def identity_key
      beacon_keypair.identity_key(resolver_public_key: resolver_public_key)
    end

    def encryptor
      @encryptor ||= EphemeralCalc::Encryptor.new(identity_key, rotation_exp)
    end

    def initial_eid
      [encryptor.get_identifier(0)].pack("H*")
    end

    def register
      beacon = ProximityBeacon::Beacon.new(
        ephemeral_id_registration: {
          beaconEcdhPublicKey: Base64.strict_encode64(beacon_keypair.public_key),
          serviceEcdhPublicKey: eid_params["serviceEcdhPublicKey"],
          rotationPeriodExponent: rotation_exp,
          initialClockValue: encryptor.beacon_time,
          initialEid: Base64.strict_encode64(initial_eid)
        },
        advertised_id: ProximityBeacon::AdvertisedId.new(
          eddystone_ids: [namespace, instance]
        ),
        status: "ACTIVE",
        description: self.description,
      )
      registered_beacon = api_client.beacons.register(beacon)
      @beacon_name = registered_beacon.name
    end

    def as_yaml
      {
        beacon_name: beacon_name,
        identity_key: identity_key,
        rotation_exp: rotation_exp,
        initial_time: encryptor.initial_time,
      }
    end

    def to_yaml
      as_yaml.to_yaml
    end

  private

    def random_instance
      SecureRandom.random_bytes(6).unpack("H*")[0]
    end

  end
end
