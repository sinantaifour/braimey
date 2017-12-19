#! /usr/bin/env ruby
# A good starting point for details for BitCoin and LiteCoin:
# https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses
# For Ethereum, this code is based off:
# https://github.com/SilentCicero/ethereumjs-accounts

require_relative 'keys_generation'
require_relative 'key_stretching'
require_relative 'keys_representation'
require_relative 'argon_stretching'
require 'digest'
require 'io/console'
require 'digest/sha3'
require 'optparse'

# Read the input.
# ===============

def parse_args(args)
  if args.length == 0
    print("No arguments passed. Check help (-h) for the options \n")
    exit()
  end
  # Options and null options object
  options = {}
  options[:expansion] = false
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

The protocol argument can be anywhere between full argument (beginning, middle, last). examples:
    ruby braimey.rb bitcoin -s <seed> ...
    ruby braimey.rb -i -t 10 LTC -e argon
    ruby braimey -t 10 ethereum -p -e looped

Whereas the following is wrong:
    ruby braimey -t ethereum 10 -p -e looped

    EOE

    opts.separator ""
    opts.separator "Options:"
    opts.separator "  phrase input:"

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

    opts.separator "  expansion options:"
    opts.on("-e", "--expansion [METHOD]", "The Expansion method to use. Can be one of: [argon, looped]") do |exp|
      options[:expansion] = :argon if exp == "argon"
      options[:expansion] = :looped if exp == "looped"
      raise("Invalid expansion method: #{exp}") unless options[:expansion]
    end

    opts.on("-t", "--iterations [COUNT]", Integer,
            "The number/time for the selected expansion method.") do |it|
      options[:iterations] = it
    end

    opts.separator "  other options:"
    opts.on_tail("-h", "--help", "Show help text") do
      puts opts
      print "\n", protocols_help
      exit

    opts.separator ""

    end
  end

  opt_parser.parse!(args)

  raise("No pass phrase source selected. Please provide either -s(eed), -p(rompt), or -i(nput)") unless options[:source]
  raise("No expansion method selected, but iterations were set") if options[:iterations] > 0 and !options[:expansion]
  raise("No iterations were set, but expansion method was selected") if options[:iterations] == 0 and options[:expansion]

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

if options[:expansion] == :looped
  phrase_stretching = LoopedShaStretching.new(options[:iterations])
elsif options[:expansion] == :argon
  phrase_stretching = ArgonStretching.new(options[:iterations])
else
  phrase_stretching = LoopedShaStretching.new(0)
end

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
