require 'rspec'
require_relative '../argon_stretching'

describe 'ArgonStretching' do
  input = "thistestthissaltthistestthisphrase"
  it 'should hash the input phrase once if the count is set to one' do
    expander = ArgonStretching.new(100)
    expected_output = "$argon2i$v=19$m=65536,t=100,p=1$dGhpc3Rlc3R0aGlzc2FsdA$sLs+sGPc+0nSIXMrOrVjh6ZhyOxDX4btkkIdtHm+miQ"
    expect(expander.expand_phrase(input)).to eql(expected_output)
  end

  it 'should hash the input phrase twice if the count is set to two' do
    expander = ArgonStretching.new(200)
    expected_output = "$argon2i$v=19$m=65536,t=200,p=1$dGhpc3Rlc3R0aGlzc2FsdA$R8PagOHmTi08HhL6Vc1f509jI+OAzRNapNmExJtagwI"
    expect(expander.expand_phrase(input)).to eql(expected_output)
  end
end