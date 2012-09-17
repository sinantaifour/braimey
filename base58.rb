# Adapated from pywallet.
# Implements the variant of Base58 encoding used in BitCoin.

require 'bigdecimal' # TODO: might not be needed, could probably work with Bignum.

class Base58 # TODO: probably doesn't play well with unicode.

  CHARS = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
  BASE = CHARS.length

  def self.encode58(str)
    # Turn the string into a number.
    num = BigDecimal.new(0)
    str.split("").reverse.each_with_index do |c, i|
      num += c.ord * (256) ** i
    end
    # Turn the number into a string using the Base58 alphabet.
    res = ""
    while num > 0 do
      mod = num % BASE
      res = CHARS[mod] + res
      num = (num - mod) / BASE
    end
    # Encoding leading zeros, every leading zero byte is replaced with an
    # instance of CHARS[0] (thus doing a bit of leading-zero compression).
    num_leading_zeros = str.split("").inject(0) { |a, c| break a if c.ord != 0; a + 1 }
    CHARS[0] * num_leading_zeros + res
  end

  def self.decode58(str)
    # Strip leading zeros.
    num_leading_zeros = str.split("").inject(0) { |a, c| break a if c != CHARS[0]; a + 1 }
    str = str[num_leading_zeros..-1]
    # Turn the string into a number.
    num = BigDecimal.new(0)
    str.split("").reverse.each_with_index do |c, i|
      num += CHARS.index(c) * BASE ** i
    end
    # Get the binary representation of the number.
    res = ""
    while num > 0 do
      mod = num % 256
      res = mod.to_i.chr + res
      num = (num - mod) / 256
    end
    # Add back the leading zeros.
    0.chr * num_leading_zeros + res
  end

end
