require 'digest'
require 'digest/sha3'

class PhraseExpansion
  def expand_phrase(phrase)
    raise NotImplementedError
  end
end

class LoopedShaExtension < PhraseExpansion
  def initialize(count)
    @count = count
    @expansion_method = Proc.new do |phrase| Digest::SHA256.hexdigest(phrase) end
  end

  def expand_phrase(phrase)
    return phrase if phrase == ""
    expanded_phrase = phrase
    @count.times { expanded_phrase = @expansion_method.call(expanded_phrase) }
    expanded_phrase
  end
end