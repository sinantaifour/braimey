require 'rspec'
require_relative '../keys_representation'

describe 'PublicKeysRepresentation' do
  representor = PublicKeyRepresentation.new

  context "for unknown protocols" do
    protocol = nil
    it 'should silently return an empty string' do
      input = ["", ""]
      expected_output = ""
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)
    end
  end

  context "for bitcoin protocol" do
    protocol = :bitcoin
    it 'should silently return an empty string for malformed inputs' do
      input = ""
      expected_output = ""
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)

      input = "This is a malformed input"
      expected_output = ""
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)
    end

    it 'should return the expected output for a given input' do
      input = ["t", "h"]
      expected_output = "18sDSsJPoGNSZau6GMs95BM6nSe4T41ird"
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)
    end
  end

  context "for litecoin protocol" do
    protocol = :litecoin
    it 'should silently return an empty string for malformed inputs' do
      input = ""
      expected_output = ""
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)

      input = "this is a malformed input"
      expected_output = ""
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)
    end

    it 'should return the expected output for a given input' do
      input = ["t", "h"]
      expected_output = "LT6Ai5cDsvcVpPbFSVrSMCQrzf1LVcfKk4"
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)
    end
  end

  context "for ethereum protocol" do
    protocol = :ethereum
    it 'should silently return an empty string for malformed inputs' do
      input = ""
      expected_output = ""
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)

      input = "Malformed input"
      expected_output = ""
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)
    end

    it 'should return the expected output for an input' do
      input = ["t", "h"]
      expected_output = "0x334dbde866c9b8b039036b87c5eb2fd89bcb6bab"
      expect(representor.hex_key_to_import_format(input, protocol)).to eql(expected_output)
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
