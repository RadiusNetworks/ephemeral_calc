require 'openssl'

module EphemeralCalc
  class Encryptor

    attr_accessor :identity_key
    attr_accessor :rotation_scalar
    attr_accessor :initial_time

    def initialize(identity_key, rotation_scalar, initial_time = Time.now)
      if identity_key.size == 32
        # 32 characters means this is a 16-byte hex string
        self.identity_key = [identity_key].pack("H*")
      else
        self.identity_key = identity_key
      end
      self.rotation_scalar = rotation_scalar
      self.initial_time = initial_time.to_i
    end

    def beacon_time
      Time.now.to_i - self.initial_time
    end

    def quantum
      beacon_time / (2**rotation_scalar)
    end

    # Output is an 8-byte encrypted identifier as a hex string
    # e.g. "0102030405060708"
    def get_identifier(beacon_time = nil)
      beacon_time ||= self.beacon_time
      return nil if beacon_time < 0
      temporary_key = do_aes_encryption(self.identity_key, key_generation_data_block(beacon_time))
      encrypted_data = do_aes_encryption(temporary_key, data_block(beacon_time)).bytes.to_a
      # the identifier is the first 8 bytes of the encrypted output
      identifier_array = encrypted_data[0,8]
      identifier_array.map{|b| sprintf("%02X",b)}.join
    end

    # yields the current EID and each subsuquent EID, until the block returns :stop
    def each_identifier
      last_quantum = nil
      loop do
        if quantum != last_quantum
          last_quantum = quantum
          break if :stop == yield( get_identifier )
        end
        sleep 1
      end
    end

  private

    def seconds_counter_32_bit(time_in_seconds)
      time_in_seconds ||= Time.now.to_i
      time_in_seconds.to_i & 0xffffffff
    end

    def key_generation_data_block(time_in_seconds=nil)
      time_b2 = (seconds_counter_32_bit(time_in_seconds) >> 16) & 0xff
      time_b3 = (seconds_counter_32_bit(time_in_seconds) >> 24) & 0xff
      [
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0xff,
        0, 0, time_b3, time_b2
      ].pack('c*')
    end

    # this is the 16 byte block to encrypt as an array of 16 numbers
    def data_block(time_in_seconds=nil)
      time = seconds_counter_32_bit(time_in_seconds) & (0xffffffff - (2**rotation_scalar-1))
      time_b0 = time & 0xff
      time_b1 = (time >> 8) & 0xff
      time_b2 = (time >> 16) & 0xff
      time_b3 = (time >> 24) & 0xff
      [
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, rotation_scalar,
        time_b3, time_b2, time_b1, time_b0
      ].pack('c*')
    end

    def do_aes_encryption(key, data)
      aes = OpenSSL::Cipher.new("AES-128-ECB")
      aes.encrypt
      aes.key = key[0, aes.key_len]
      aes.update(data) + aes.final
    end
  end
end
