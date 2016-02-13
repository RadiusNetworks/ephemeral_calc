require 'openssl'

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
        Curve25519.mult(self.private_key, Curve25519::BASEPOINT)
      end
    end

    def shared_secret(other_public_key)
      Curve25519.mult(self.private_key, other_public_key)
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
      hkdf(secret, salt)[0..15]
    end

    def convert_key(key_string)
      if key_string.size == 64
        [key_string].pack("H*")
      else
        key_string
      end
    end

    def self.generate_private_key
      # reference: https://code.google.com/archive/p/curve25519-donna/
      # See section on "generating a private key"
      key = SecureRandom.random_bytes(32)
      first_byte = key[0].unpack("C")[0] & 248
      key[0] = [first_byte].pack("C")
      last_byte = (key[31].unpack("C")[0] & 127) | 64
      key[31] = [last_byte].pack("C")
      return key
    end

    def hkdf(secret, salt)
      digest = OpenSSL::Digest.new("SHA256")
      prk = OpenSSL::HMAC.digest(digest, salt, secret)
      OpenSSL::HMAC.digest(digest, prk, "\x01")
    end
  end
end
