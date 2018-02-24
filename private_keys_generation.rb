require 'digest'
require 'digest/sha3'


# I am not familiar with bip39 yet, it could be possible that we have to abstract the expansion and generation,
# based on which implementation is opted for.
class PrivateKeysGeneration
  def initialize(phrase_expander)
    @key_stretcher = phrase_expander
  end

  def generate_key(seed)
    return "" if seed == ""
    expanded_seed = @key_stretcher.expand_phrase(seed)
    Digest::SHA256.hexdigest(expanded_seed)
  end
end


