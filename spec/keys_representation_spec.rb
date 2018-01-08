require 'rspec'
require_relative '../keys_representation'

describe 'PublicKeysRepresentation' do
  representor = PublicKeyRepresentation.new

  valid_input = ["5f81956d5826bad7d30daed2b5c8c98e72046c1ec8323da336445476183fb7ca", "54ba511b8b782bc5085962412e8b9879496e3b60bebee7c36987d1d5848b9a50"]
  invalid_input_empty = ""
  invalid_input_not_array = "This is a malformed input"
  invalid_input_not_hex = ["this is a", "malformed input"]

  context "for unknown protocols" do
    protocol = nil
    it 'should silently return an empty string' do
      expected_output = ""
      expect(representor.hex_key_to_import_format(valid_input, protocol)).to eql(expected_output)
    end
  end

  context "for bitcoin protocol" do
    protocol = :bitcoin
    it 'should silently return an empty string for malformed inputs' do
      expected_output = ""

      expect(representor.hex_key_to_import_format(invalid_input_empty, protocol)).to eql(expected_output)
      expect(representor.hex_key_to_import_format(invalid_input_not_array, protocol)).to eql(expected_output)
      expect(representor.hex_key_to_import_format(invalid_input_not_hex, protocol)).to eql(expected_output)
    end

    it 'should return the expected output for a given input' do
      expected_output = "1HKqKTMpBTZZ8H5zcqYEWYBaaWELrDEXeE"
      expect(representor.hex_key_to_import_format(valid_input, protocol)).to eql(expected_output)
    end
  end

  context "for litecoin protocol" do
    protocol = :litecoin
    it 'should silently return an empty string for malformed inputs' do
      expected_output = ""

      expect(representor.hex_key_to_import_format(invalid_input_empty, protocol)).to eql(expected_output)
      expect(representor.hex_key_to_import_format(invalid_input_not_array, protocol)).to eql(expected_output)
      expect(representor.hex_key_to_import_format(invalid_input_not_hex, protocol)).to eql(expected_output)
    end

    it 'should return the expected output for a given input' do
      expected_output = "LbYnaffeG7ocP5n9nyXXnZFLnibd27wms5"
      expect(representor.hex_key_to_import_format(valid_input, protocol)).to eql(expected_output)
    end
  end

  context "for ethereum protocol" do
    protocol = :ethereum
    it 'should silently return an empty string for malformed inputs' do
      expected_output = ""

      expect(representor.hex_key_to_import_format(invalid_input_empty, protocol)).to eql(expected_output)
      expect(representor.hex_key_to_import_format(invalid_input_not_array, protocol)).to eql(expected_output)
      expect(representor.hex_key_to_import_format(invalid_input_not_hex, protocol)).to eql(expected_output)
    end

    it 'should return the expected output for an input' do
      expected_output = "0x2a260a110bc7b03f19c40a0bd04ff2c5dcb57594"
      expect(representor.hex_key_to_import_format(valid_input, protocol)).to eql(expected_output)
    end
  end
end


describe 'PrivateKeyRepresentation' do
  representor = PrivateKeyRepresentation.new

  context "for unknown protocols" do
    protocol = nil
    it 'should silently return an empty string' do
      input = ""
      expected_output = ""
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)
    end
  end

  context "for bitcoin protocol" do
    protocol = :bitcoin
    it 'should silently return an empty string for empty inputs' do
      input = ""
      expected_output = ""
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)
    end

    it 'should return the expected output for a given input' do
      input = "thisisatest"
      expected_output = "YwicSzfHvyGp6QC"
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)
    end
  end

  context "for litecoin protocol" do
    protocol = :litecoin
    it 'should silently return an empty string for empty inputs' do
      input = ""
      expected_output = ""
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)
    end

    it 'should return the expected output for a given input' do
      input = "thisisatest"
      expected_output = "kr5cjJ1C3BiiFmH"
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)
    end
  end

  context "for ethereum protocol" do
    protocol = :ethereum
    it 'should silently return an empty string for empty inputs' do
      input = ""
      expected_output = ""
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)
    end

    it 'should return the expected output for a given input' do
      input = "thisisatest"
      expected_output = "thisisatest"
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)
    end
  end
end
