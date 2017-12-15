require './base58'

class KeysRepresentation
  def hex_key_to_import_format(key, protocol)
    raise NotImplementedError
  end
end

class PrivateKeyRepresentation < KeysRepresentation
  def hex_key_to_import_format(priv, protocol)
    if [:litecoin, :bitcoin].include?(protocol)
      version = { :litecoin => "B0", :bitcoin => "80" }[protocol]
      extpriv = [version + priv].pack("H*")
      csm = Digest::SHA256.digest(Digest::SHA256.digest(extpriv))[0..3]
      Base58.encode58(extpriv + csm)
    elsif protocol == :ethereum
      priv
    end
  end
end

class PublicKeyRepresentation < KeysRepresentation
  def hex_key_to_import_format(pub, protocol)
    if [:litecoin, :bitcoin].include?(protocol)
      intermediate = ["04" + ("0" * 64 + pub[0])[-64..-1]+ ("0" * 64 + pub[1])[-64..-1]].pack("H*")
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
      padded = ("0" * 64 + pub[0])[-64..-1]+ ("0" * 64 + pub[1])[-64..-1]
      "0x" + Digest::SHA3.hexdigest([padded].pack("H*"), 256)[-40..-1]
    end
  end
end


