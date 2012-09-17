# Adapated from pywallet, in term adapted from python-ecdsa.
# Has a subset of an ECDSA implementation, to generate a public key from a
# private key.

module ECDSA
  class Point

    attr_reader :p, :a, :b, :x, :y, :order

    def initialize(p, a, b, x, y, order = nil)
      @p = p; @a = a; @b = b; @x = x; @y = y; @order = order
    end

    def +(other)
      return self if other == INFINITY
      return other if self == INFINITY
      if @x == other.x
        if (@y + other.y) % @p == 0
          return INFINITY
        else
          return double()
        end
      end
      l = ((other.y - @y) * inverse_mod(other.x - @x, p)) % p
      x3 = (l * l - @x - other.x) % p
      y3 = (l * (@x - x3) - @y) % p
      return Point.new(@p, @a, @b, x3, y3)
    end

    def *(num)
      e = num
      e = e % @order if @order
      return INFINITY if e == 0
      return INFINITY if self == INFINITY
      negative_self = Point.new(@p, @a, @b, @x, -@y, @order)
      e3 = 3 * e
      i = leftmost_bit(e3) / 2
      res = self
      while i > 1 do
        res = res.double
        res = res + self if (e3 & i) != 0 && (e & i) == 0
        res = res + negative_self if (e3 & i) == 0 && (e & i) != 0
        i = i / 2
      end
      res
    end

    def double
      return INFINITY if self == INFINITY
      l = ((3 * @x * @x + @a) * inverse_mod(2 * @y, p)) % p
      x3 = (l * l - 2 * @x) % p
      y3 = (l * (@x - x3) - @y) % p
      Point.new(@p, @a, @b, x3, y3)
    end

    private

    def leftmost_bit(x)
      res = 1
      while res <= x do
        res = 2 * res
      end
      return res / 2
    end

    def inverse_mod(a, m)
      a = a % m if a < 0 || m <= a
      c, d = a, m
      uc, vc, ud, vd = 1, 0, 0, 1
      while c != 0 do
        q, c, d = [*d.divmod(c), c]
        uc, vc, ud, vd = ud - q * uc, vd - q * vc, uc, vc
      end
      ud > 0 ? ud : ud + m
    end

    Point::INFINITY = Point.new(nil, nil, nil, nil, nil)

  end
end
