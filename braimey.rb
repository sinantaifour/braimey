#! /usr/bin/env ruby
# A good starting point for details for BitCoin and LiteCoin:
# https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses
# For Ethereum, this code is based off:
# https://github.com/SilentCicero/ethereumjs-accounts

require_relative 'keys_generation'
require_relative 'key_stretching'
require_relative 'keys_representation'
require 'digest'
require 'io/console'
require 'digest/sha3'
require 'optparse'

# Read the input.
# ===============

def parse_args(args)
  # Options and null options object
  options = {}
  options[:iterations] = 0
  options[:source] = nil
  options[:seed] = ""
  options[:source] = nil
  options[:protocol] = :null

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

def retrieve_seed(options)
  seed = ""
  if options[:source] == :seed
    seed = options[:seed]
  elsif options[:source] == :prompt
    print "Enter the passphrase: "
    seed = STDIN.noecho {|io| io.gets}.gsub("\n", "")
    print "\n"
    print "Re-enter the passphrase: "
    unless STDIN.noecho {|io| io.gets}.gsub("\n", "") == seed
      print "\n\e[31mPassphrases don't match.\e[0m\nShowing results for first passphrase."
    end
    print "\n"
  elsif options[:source] == :input
    seed = STDIN.readline.gsub("\n", "")
  end
  raise("Seed was not provided. Check your syntax") if seed == ""
  seed
end

# Parse options based on arguments.
# =================================

options = parse_args(ARGV)
seed = retrieve_seed(options)

# Generate keys.
# ==============

phrase_stretching = LoopedShaStretching.new(options[:iterations])
private = PrivateKeysGeneration.new(phrase_stretching).generate_key(seed)
public = PublicKeysGeneration.new.generate_key(private)

# Format and output.
# ==================
#
puts "\e[34mAddresses for the #{options[:protocol].capitalize} network.\e[0m"
puts "Hash: #{private}."
public_hex = PublicKeyRepresentation.new.hex_key_to_import_format(public, options[:protocol])
private_hex = PrivateKeyRepresentation.new.hex_key_to_import_format(private, options[:protocol])
puts "Address Pair: #{public_hex}:#{private_hex}."
