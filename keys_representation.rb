require 'digest'
require 'digest/sha3'
require_relative 'base58'

class PrivateKeyRepresentation
  def hex_key_to_import_format(priv, protocol)
    if priv == ""
      return priv
    end

    if [:litecoin, :bitcoin].include?(protocol)
      version = { :litecoin => "B0", :bitcoin => "80" }[protocol]
      extpriv = [version + priv].pack("H*")
      csm = Digest::SHA256.digest(Digest::SHA256.digest(extpriv))[0..3]
      Base58.encode58(extpriv + csm)
    elsif protocol == :ethereum
      priv
    else
      nil
    end
  end
end

class PublicKeyRepresentation
  def hex_key_to_import_format(pub, protocol)
    if not pub.is_a? Array and pub.length != 2
      return ""
    end

    if pub[0][/\H/] or pub[1][/\H/]
      return ""
    end

    if [:litecoin, :bitcoin].include?(protocol)
      intermediate = ["04" + pub[0] + pub[1]].pack("H*")
      intermediate = Digest::SHA256.digest(intermediate)
      intermediate = Digest::RMD160.digest(intermediate)
      version = { :litecoin => "0", :bitcoin => "\x00" }[protocol]
      intermediate = version + intermediate
      extended = intermediate
      intermediate = Digest::SHA256.digest(intermediate)
      intermediate = Digest::SHA256.digest(intermediate)
      csm = intermediate[0..3]
      Base58.encode58(extended + csm)
    elsif protocol == :ethereum
      padded = pub[0] + pub[1]
      "0x" + Digest::SHA3.hexdigest([padded].pack("H*"), 256)[-40..-1]
    else
      ""
    end
  end
end


