#! /usr/bin/env ruby
# A good starting point for details:
# https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses

require './base58'
require './ecdsa'
require 'digest'
require 'io/console'

def hex_private_key_to_wallet_import_format(priv)
  extpriv = ["80" + priv].pack("H*")
  csm = Digest::SHA256.digest(Digest::SHA256.digest(extpriv))[0..3]
  Base58.encode58(extpriv + csm)
end

def hex_public_key_to_wallet_import_format(pub)
  intermediate = [pub].pack("H*")
  intermediate = Digest::SHA256.digest(intermediate)
  intermediate = Digest::RMD160.digest(intermediate)
  intermediate = "\x00" + intermediate
  extended = intermediate
  intermediate = Digest::SHA256.digest(intermediate)
  intermediate = Digest::SHA256.digest(intermediate)
  csm = intermediate[0..3]
  Base58.encode58(extended + csm)
end

def hex_private_key_to_hex_public_key(priv)
  p = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F".to_i(16)
  a = "0000000000000000000000000000000000000000000000000000000000000000".to_i(16)
  b = "0000000000000000000000000000000000000000000000000000000000000007".to_i(16)
  gx = "79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798".to_i(16)
  gy = "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8".to_i(16)
  r = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141".to_i(16)
  point = ECDSA::Point.new(p, a, b, gx, gy, r)
  res = point * priv.to_i(16)
  "04" + ("0" * 64 + res.x.to_s(16))[-64..-1]+ ("0" * 64 + res.y.to_s(16))[-64..-1]
end

seed = nil
if ARGV[0] == "-s"
  seed = ARGV[1]
elsif ARGV[0] == "-p"
  print "Enter the passphrase: "
  seed = STDIN.noecho { |io| io.gets }.gsub("\n", "")
  print "\n"
  print "Re-enter the passphrase: "
  unless STDIN.noecho { |io| io.gets }.gsub("\n", "") == seed
    puts "\nPassphrases don't match."
    exit(1)
  end
  print "\n"
elsif ARGV[0] == "-i"
  seed = STDIN.readline.gsub("\n", "")
end
unless seed
  puts "Must specify one of -s(eed), -p(rompt), -i(nput)."
  exit(1)
end

priv = Digest::SHA256.hexdigest(seed)
pub = hex_private_key_to_hex_public_key(priv)
# puts %Q{Seed: "#{seed}".}
puts %Q{Hash: #{priv}.}
puts %Q{Address Pair: #{hex_public_key_to_wallet_import_format(pub)}:#{hex_private_key_to_wallet_import_format(priv)}.}
