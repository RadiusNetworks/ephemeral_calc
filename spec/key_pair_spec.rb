require 'spec_Helper'

module EphemeralCalc
  RSpec.describe KeyPair do
    let(:resolver_private_key) { "61136adab1bf302f1c49e860196aeefd8fbaa41518b4c226372d6cc469c47278" }
    let(:resolver_public_key)  { "29769a045dcb811ba3025985b9de91eb9a57dadbceb68a1e6a3c2b1af4868e1f" }
    let(:resolver_key) { KeyPair.new resolver_private_key }

    let(:beacon_private_key) {"6ea13b5ef3cc642fd6102c1d85c096b510f56efc488114a4562a987bf4525628"}
    let(:beacon_public_key)  {"c63e6f89aab47552c8d621a59c81d0af203f6570a4bd7a267a08a17561c8bc2b"}
    let(:beacon_key) { KeyPair.new beacon_private_key }

    let(:shared_secret) { "690821890fffb83bb348fb620d0a10e625fe3d919b5594e7b9258d50f829b90b" }
    let(:identity_key) { "f40d6f18e5882260e847e99ca33ac44f" }

    it "can generate a private key" do
      key_pair = KeyPair.new
      expect(key_pair.private_key.length).to eq(32)
    end

    it "can compute a public key" do
      expect(beacon_key.public_key.unpack("H*")[0]).to eq(beacon_public_key)
    end

    context "as a beacon, when given a resolvers public key" do
      it "can compute a shared secret" do
        expect(beacon_key.shared_secret(resolver_key.public_key).unpack("H*")[0]).to eq(shared_secret)
      end

      it "can compute an identity key" do
        expect(
          beacon_key.identity_key(resolver_public_key: resolver_key.public_key).unpack("H*")[0]
        ).to eq( identity_key )
      end
    end

    context "as a resolver, when given a beacon's public key" do
      it "can compute a shared secret" do
        expect(resolver_key.shared_secret(beacon_key.public_key).unpack("H*")[0]).to eq(shared_secret)
      end

      it "can compute an identity key" do
        expect(
          resolver_key.identity_key(beacon_public_key: beacon_key.public_key).unpack("H*")[0]
        ).to eq( identity_key )
      end
    end

  end
end
