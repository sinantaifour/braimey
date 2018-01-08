#! /usr/bin/env ruby

def run(protocol, result)
  print "Testing #{protocol} ... "
  if `ruby ../braimey.rb #{protocol} -s "thisisatest"`.split("\n").grep(/Address Pair/).first.split(": ").last == result + "."
    puts "OK."
  else
    puts "FAILED!"
  end
end

run("bitcoin", "1GLyv3DuCKGGhMCa9JEkCCjbR2UMcTmB69:5K6BU1VoDiGSkAVpwyu5YgxnmuiGwNyVW5RLtAnDkyS3tqAL5Jz")
run("litecoin", "LaZwBFXjGyWKx9tjKSE3UDoMdEqdk8ngjw:6vPuw93L88jKDYPgToh3L5jxjPGk9BRXGkpWbMoFURkfacZbYRS")
run("ethereum", "0xc31b85901fceb7f4d56d1dc55ba5b3fb57f300a7:a7c96262c21db9a06fd49e307d694fd95f624569f9b35bb3ffacd880440f9787")
