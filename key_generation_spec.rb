require 'rspec'
require_relative 'keys_generation'
require_relative 'phrase_expansion'

class ExpanderMock < PhraseExpansion
  def self.expand_phrase(phrase)
    phrase
  end
end

describe 'PublicKeyGeneration' do
  expander = ExpanderMock
  context 'private key generation' do
    generator = PrivateKeysGeneration.new(expander)
    it 'should return an empty key if there is an empty seed' do
      input = ""
      expected_output = input
      expect(generator.generate_key(input)).to eql(expected_output)
    end

    it 'should return an expected output for a test input' do
      input = "test"
      expected_output = "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"
      expect(generator.generate_key(input)).to eql(expected_output)
    end
  end

  context 'public key generation' do
    generator = PublicKeysGeneration.new
    it 'should return an empty key if there is an empty seed' do
      input = ""
      expected_output = input
      expect(generator.generate_key(input)).to eql(expected_output)
    end

    it 'should return expected output for a fixed input' do
      input = "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"
      expected_output = ["5f81956d5826bad7d30daed2b5c8c98e72046c1ec8323da336445476183fb7ca", "54ba511b8b782bc5085962412e8b9879496e3b60bebee7c36987d1d5848b9a50"]
      expect(generator.generate_key(input)).to eql(expected_output)
    end
  end

end

