require 'rspec'
require_relative '../private_keys_generation'
require_relative '../public_key_generation'

class StretchingMock
  def self.expand_phrase(phrase)
    phrase
  end
end


def get_random_string(len)
  source = ("a".."f").to_a + ("0".."9").to_a
  (0..len).map { source[rand(source.size)] }.join("")
end

describe 'KeysGeneration' do

  property_tests_iterations = 200
  context 'private key generation' do
    expander = StretchingMock
    generator = PrivateKeysGeneration.new(expander)

    # Some property testing
    it 'should always generate the same output length regardless of the input size' do
      expected_length = 64
      (2..property_tests_iterations).each do |i|
        input = get_random_string(i)
        expect(generator.generate_key(input).length).to eql(expected_length)
      end
    end

    it 'should generate unique keys for different inputs' do
      inputs = []
      keys = []
      (0..property_tests_iterations).each do
        input = get_random_string(50)
        continue if inputs.include? input
        inputs.push(input)

        keys.push(generator.generate_key(input))
      end

      expect(keys.length).to eql(keys.uniq.length), "there was a collision in the private key creation for the following inputs: #{inputs}"

    end

    # some value testing
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

    # Some property testing
    # Tests are still failing, despite using a local generator created in each loop
    it 'should always generate the same output length regardless of the input size' do
      max_length = 64
      (0..property_tests_iterations).each do
        # Seems ECDSA can only be used once per instance. Therefore, recreating the genreator every loop
        input = get_random_string(64)

        public_key = generator.generate_key(input)

        expect(public_key[0].length).to be <= max_length
        expect(public_key[1].length).to be <= max_length
      end
    end

    it 'should generate unique keys for different inputs' do
      inputs = []
      keys = []
      property_tests_iterations.times do
        input = get_random_string(64)
        continue if inputs.include? input
        inputs.push(input)

        keys.push(generator.generate_key(input))
      end

      expect(keys.length).to eql(keys.uniq.length), "there was a collision in the public key creation for the following inputs: #{inputs}"
    end

    # Some value testing
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

