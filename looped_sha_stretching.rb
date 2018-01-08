require 'digest'
require 'digest/sha3'

class LoopedShaStretching
  EXPANSION_METHOD = Proc.new { |phrase| Digest::SHA256.hexdigest(phrase)}

  def initialize(count)
    @count = count
  end

  def expand_phrase(phrase)
    return phrase if phrase == ""
    expanded_phrase = phrase
    @count.times { expanded_phrase = EXPANSION_METHOD.call(expanded_phrase) }
    expanded_phrase
  end
end

