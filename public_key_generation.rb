require_relative 'ecdsa'


class PublicKeysGeneration
  def generate_key(private_key)
    return "" if private_key == ""
    p = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F".to_i(16)
    a = "0000000000000000000000000000000000000000000000000000000000000000".to_i(16)
    b = "0000000000000000000000000000000000000000000000000000000000000007".to_i(16)
    gx = "79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798".to_i(16)
    gy = "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8".to_i(16)
    r = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141".to_i(16)
    point = ECDSA::Point.new(p, a, b, gx, gy, r)
    res = point * private_key.to_i(16)
    [(res.x.to_s(16).rjust(64,"0")), (res.y.to_s(16).rjust(64, "0"))]
  end
end
