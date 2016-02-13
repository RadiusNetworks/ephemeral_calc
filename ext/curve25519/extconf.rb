# Loads mkmf which is used to make makefiles for Ruby extensions
require 'mkmf'

# Give it a name
extension_name = 'ephemeral_calc/curve25519'

# The destination
dir_config(extension_name)

create_makefile(extension_name)

