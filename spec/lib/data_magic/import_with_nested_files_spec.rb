require 'spec_helper'
require 'data_magic'

describe "unique key(s)" do
  before :example do
    DataMagic.destroy
    ENV['DATA_PATH'] = './spec/fixtures/nested_files'
    DataMagic.config = DataMagic::Config.new
    DataMagic.import_with_dictionary
  end
  after :example do
    DataMagic.destroy
  end
  let(:query)   { {} }
  let(:sort)    { nil }
  let(:result)  { DataMagic.search(query, sort: sort) }
  let(:first)   { result['results'].first }
  let(:total)   { result['metadata']['total'] }

  it "creates one document per unique id" do
    expect(total).to eq(10)
  end

  context "can import a subset of fields" do
    context "and when searching for a field value" do
      let(:query) { { zipcode: "35762" } }
      it "and doesn't find column" do
        expect(total).to eq(0)
      end
    end
    it "and doesn't include extra field" do
      expect(first['zipcode']).to be(nil)
    end
  end

  context "when searching on a nested field" do
    let(:query) { { '2013.earnings.6_yrs_after_entry.median' => 26_318 } }
    it "can find the correct results" do
      expect(total).to eq(1)
      expect(first['2013']['earnings']['6_yrs_after_entry']).to eq("percent_gt_25k" => 0.53, "median" => 26_318)
    end
  end

  context "when sorting by a nested field" do
    let(:sort) { '2013.earnings.6_yrs_after_entry.median' }
    it "can find the right first result" do
      expect(total).to eq(10)
      expect(first['2013']['earnings']['6_yrs_after_entry']).to eq("percent_gt_25k" => 0.09, "median" => 1836)
    end
  end
end
