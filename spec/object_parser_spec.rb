require 'spec_helper'

describe Mkm::Parser do
  def load_sample_file(file)
    File.read(File.join(File.dirname(__FILE__), "samples/#{file}.xml"))
  end

  it "parses games" do
    expect( subject.parse_games(load_sample_file("games")) ).
      to eql([{:id => 1, :name => "Magic the Gathering"}, {:id => 2, :name => "Another game"}])
  end

  it "parses products" do
    products = subject.parse_products(load_sample_file("products_search"))
    expect( products.size ).to eql(3)
    expect( products.first ).
      to eql({
               :id => 20964,
               :metaproduct_id => 10498,
               :name => "Zealous Persecution",
               :low_price => 45,
               :sell_price => 86,
               :avg_price => 163,
               :expansion => "Alara Reborn",
               :rarity => "Uncommon"
             })
  end
end
