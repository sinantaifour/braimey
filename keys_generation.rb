require 'digest'
require 'digest/sha3'
require_relative 'ecdsa'

class KeysGeneration
  def generate_key(seed)
    raise NotImplementedError
  end
end

# I am not familiar with bip39 yet, it could be possible that we have to abstract the expansion and generation,
# based on which implementation is opted for.
class PrivateKeysGeneration < KeysGeneration
  def initialize(phrase_expander)
    @phrase_expander = phrase_expander
  end

  def generate_key(seed)
    return "" if seed == ""
    expanded_seed = @phrase_expander.expand_phrase(seed)
    Digest::SHA256.hexdigest(expanded_seed)
  end
end

class PublicKeysGeneration < KeysGeneration
  def generate_key(seed)
    return "" if seed == ""
    p = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F".to_i(16)
    a = "0000000000000000000000000000000000000000000000000000000000000000".to_i(16)
    b = "0000000000000000000000000000000000000000000000000000000000000007".to_i(16)
    gx = "79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798".to_i(16)
    gy = "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8".to_i(16)
    r = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141".to_i(16)
    point = ECDSA::Point.new(p, a, b, gx, gy, r)
    res = point * seed.to_i(16)
    [res.x.to_s(16), res.y.to_s(16)]
  end
end

