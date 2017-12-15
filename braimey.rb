#! /usr/bin/env ruby
# A good starting point for details for BitCoin and LiteCoin:
# https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses
# For Ethereum, this code is based off:
# https://github.com/SilentCicero/ethereumjs-accounts

require './base58'
require './ecdsa'
require 'digest'
require 'io/console'
require 'digest/sha3'
require 'optparse'

def hex_private_key_to_import_format(priv, protocol)
  if [:litecoin, :bitcoin].include?(protocol)
    version = { :litecoin => "B0", :bitcoin => "80" }[protocol]
    extpriv = [version + priv].pack("H*")
    csm = Digest::SHA256.digest(Digest::SHA256.digest(extpriv))[0..3]
    Base58.encode58(extpriv + csm)
  elsif protocol == :ethereum
    priv
  end
end

def hex_public_key_to_import_format(pub, protocol)
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

def hex_private_key_to_hex_public_key(priv)
  p = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F".to_i(16)
  a = "0000000000000000000000000000000000000000000000000000000000000000".to_i(16)
  b = "0000000000000000000000000000000000000000000000000000000000000007".to_i(16)
  gx = "79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798".to_i(16)
  gy = "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8".to_i(16)
  r = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141".to_i(16)
  point = ECDSA::Point.new(p, a, b, gx, gy, r)
  res = point * priv.to_i(16)
  [res.x.to_s(16), res.y.to_s(16)]
end

# Read the input.
# ===============

def parse_args(args)
  # Args and defaults
  options = {}
  options[:iterations] = 0
  options[:source] = nil

  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: braimey.rb [options] protocol"
    protocols_help = <<-EOE
Select one of the following protocols:
    bitcoin: Bitcoin, bitcoin, or BTC
    litecoin: Litecoin, litecoin, or LTC
    ethereum: Ethereum, ethereum, or ETH

The protocol can be the last argument or between any full argument. example:
    ruby braimey.rb bitcoin -s <seed> ...
    ruby braimey.rb -i -e 10 LTC
    ruby braimey -e 10 ethereum -p
    EOE

    opts.separator ""
    opts.separator "Options:"

    opts.on("-s", "--seed [SEED]", "Provide pass phrase in the command") do |s|
      raise("Two sources are provided. Please provide either -s(eed), -p(rompt), or -i(nput)") if options[:source]
      options[:source] = :seed
      options[:seed] = s
    end
    opts.on("-p", "--prompt", "Provide pass phrase following the instructions in a prompt") do
      raise("Two sources are provided. Please provide either -s(eed), -p(rompt), or -i(nput)") if options[:source]
      options[:source] = :prompt
    end
    opts.on("-i", "--input", "Input the passphrase once after the command") do
      raise("Two sources are provided. Please provide either -s(eed), -p(rompt), or -i(nput)") if options[:source]
      options[:source] = :input
    end

    opts.on("-e", "--expansion [COUNT]", Integer,
            "The number of expansion iterations on the key, default 0 (take key as is)") do |it|
      options[:iterations] = it
    end

    opts.on_tail("-h", "--help", "Show help text") do
      puts opts
      print "\n", protocols_help
      exit

    opts.separator ""
    opts.separator "protocols:"

    end
  end

  opt_parser.parse!(args)

  raise("No pass phrase source seleceted. Please provide either -s(eed), -p(rompt), or -i(nput)") unless options[:source]

  protocol = args.pop
  raise "Protocol is missing and is mandetory. Please select one of ethereum, bitcoin, or litecoin" unless protocol

  raise "Too many arguments passed: #{args}. Exiting" if args.any?

  if %w(ethereum Ethereum Ether ETH).include? protocol
    options[:protocol] = :ethereum
  elsif %w(bitcoin Bitcoin BTC).include? protocol
    options[:protocol] = :bitcoin
  elsif %w(litecoin Litecoin LTC).include? protocol
    options[:protocol] = :litecoin
  else
    raise "Unknown protcol: #{protocol}. Please chose one of ethereum, bitcoin, or litecoin"
  end

  options
end

# Parse options based on arguments.
# =================================

options = parse_args(ARGV)
seed = ""
if options[:source] == :seed
  seed = options[:seed]
elsif options[:source] == :prompt
  print "Enter the passphrase: "
  seed = STDIN.noecho { |io| io.gets }.gsub("\n", "")
  print "\n"
  print "Re-enter the passphrase: "
  unless STDIN.noecho { |io| io.gets }.gsub("\n", "") == seed
    print "\n\e[31mPassphrases don't match.\e[0m\nShowing results for first passphrase."
  end
  print "\n"
elsif options[:source] == :input
  seed = STDIN.readline.gsub("\n", "")
end

raise("Seed was not provided. Check your syntax") if seed == ""

# Generate keys and output.
# =========================

priv = Digest::SHA256.hexdigest(seed)
if options[:iterations] > 0
  options[:iterations].times { priv = Digest::SHA256.hexdigest(priv) }
end

pub = hex_private_key_to_hex_public_key(priv)
puts "\e[34mAddresses for the #{options[:protocol].capitalize} network.\e[0m"
puts "Hash: #{priv}."
puts "Address Pair: #{hex_public_key_to_import_format(pub, options[:protocol])}:#{hex_private_key_to_import_format(priv, options[:protocol])}."
