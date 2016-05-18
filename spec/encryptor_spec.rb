module EphemeralCalc
  RSpec.describe Encryptor do
    let(:identity_key_hex) { "0102030405060708090A111213141516" }
    let(:identity_key) { [identity_key_hex].pack("H*") }
    let(:rotation_scalar) { 10 }

    it "can compute an eid when given a 16 byte identity key" do
      encryptor = Encryptor.new identity_key, rotation_scalar
      expect( encryptor.get_identifier ).to eq("A9B76A71C5F89290")
    end

    it "can compute an eid when given an identity key hex string" do
      encryptor = Encryptor.new identity_key_hex, rotation_scalar, (Time.now - 2000)
      expect( encryptor.get_identifier ).to eq("4144413E45FEFA58")
    end
  end
end
