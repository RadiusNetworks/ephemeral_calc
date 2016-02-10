require 'rbnacl/libsodium'
require 'hkdf'

module EphemeralCalc
  class KeyPair
    attr_reader :private_key

    def initialize(private_key = nil)
      self.private_key = private_key || KeyPair.generate_private_key
    end

    def private_key=(new_key)
      @private_key = convert_key(new_key)
    end

    def public_key
      @public_key ||= begin
        base_point = RbNaCl::GroupElements::Curve25519.base
        base_point.mult(self.private_key).to_s
      end
    end

    def shared_secret(other_public_key)
      curve_25519_my_private_key = RbNaCl::GroupElements::Curve25519.new(private_key)
      curve_22519_other_public_key = RbNaCl::GroupElements::Curve25519.new(convert_key(other_public_key))
      curve_22519_other_public_key.mult(curve_25519_my_private_key).to_bytes
    end

    # opts must contain the key :resolver_public_key or :beacon_public_key
    def identity_key(opts)
      if opts[:resolver_public_key]
        resolver_public_key = convert_key(opts[:resolver_public_key])
        beacon_public_key = self.public_key
        secret = shared_secret(resolver_public_key)
      elsif opts[:beacon_public_key]
        resolver_public_key = self.public_key
        beacon_public_key = convert_key(opts[:beacon_public_key])
        secret = shared_secret(beacon_public_key)
      else
        raise ArgumentError, "Must pass a resolver_public_key or a beacon_public_key"
      end
      salt = resolver_public_key + beacon_public_key
      HKDF.new(secret, salt: salt).next_bytes(16)
    end

    def convert_key(key_string)
      if key_string.size == 64
        [key_string].pack("H*")
      else
        key_string
      end
    end

    def self.generate_private_key
      RbNaCl::Random.random_bytes(32)
    end

  end
end
