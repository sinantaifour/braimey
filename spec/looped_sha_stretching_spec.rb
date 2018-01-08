require 'rspec'
require_relative '../looped_sha_stretching'

describe 'LoopedShaStretching' do
  it 'should should not expand an empty string, and return it as is' do
    expander = LoopedShaStretching.new(100)
    input = ""
    expected_output = ""
    expect(expander.expand_phrase(input)).to eql(expected_output)
  end

  input = "this is a test"
  it 'should return the phrase as is if the count is set to zero' do
    expander = LoopedShaStretching.new(0)
    expected_output = input
    expect(expander.expand_phrase(input)).to eql(expected_output)
  end

  it 'should hash the input phrase once if the count is set to one' do
    expander = LoopedShaStretching.new(1)
    expected_output = "2e99758548972a8e8822ad47fa1017ff72f06f3ff6a016851f45c398732bc50c"
    expect(expander.expand_phrase(input)).to eql(expected_output)
  end

  it 'should hash the input phrase twice if the count is set to two' do
    expander = LoopedShaStretching.new(2)
    expected_output = "34610a7dc634395a3f5f8b5cbcae0be10604358f04acb8f3fd63a9e9369b83d9"
    expect(expander.expand_phrase(input)).to eql(expected_output)
  end
end


