require 'rspec'
require_relative 'argon_stretching'

describe 'ArgonStretching' do
  input = "thistestthissaltthistestthisphrase"
  it 'should hash the input phrase once if the count is set to one' do
    expander = ArgonStretching.new(100)
    expected_output = "$argon2i$v=19$m=65536,t=100,p=1$YTFiMmMzZDRlNWY2ZzdoOA$IZoQKhq7Q0Aa6St0+60tshtXuyqYINkNjsbaOd9I0Bs"
    expect(expander.expand_phrase(input)).to eql(expected_output)
  end

  it 'should hash the input phrase twice if the count is set to two' do
    expander = ArgonStretching.new(200)
    expected_output = "$argon2i$v=19$m=65536,t=200,p=1$YTFiMmMzZDRlNWY2ZzdoOA$8ZCy13ffY3dnWKC/93I8j9HcPRCdr19djGjNjNDHlDM"
    expect(expander.expand_phrase(input)).to eql(expected_output)
  end
end