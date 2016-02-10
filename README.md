# EphemeralCalc

A Ruby gem that allows you to calculate ephemeral identifiers for Eddystone-EID beacons.

# Example Usage

```ruby
# insert real resolver key here
resolver_public_key = "61136adab1bf302f1c49e860196aeefd8fbaa41518b4c226372d6cc469c47278"
# generate a new key pair for the beacon
beacon_keys = EphemeralCalc::KeyPair.new
# calculate the identity key
identity_key = beacon_keys.identity_key(resolver_public_key: resolver_public_key)
# set up the encryptor
rotation_exponent = 10
encryptor = EphemeralCalc::Encryptor.new identity_key, rotation_exponent
# get the initial eid
initial_eid = encryptor.get_identifier(0)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/radiusnetworks/ephemeral_calc. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

