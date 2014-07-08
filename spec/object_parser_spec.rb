require 'rspec'
require 'ox'

module Mkm
  class Parser
    def parse_games(xml)
      Ox.parse(xml).root.nodes.map do |node|
        { :id   => node.idGame.text.to_i,
          :name => node.locate("name").first.text }
      end
    end

    def parse_products(xml)
      Ox.parse(xml).root.nodes.map do |node|
        { 
          :id => node.idProduct.text.to_i,
          :metaproduct_id => node.idMetaproduct.text.to_i,
          :expansion => node.expansion.text,
          :rarity => node.rarity.text,
          :name => node.locate("name").detect {|n| n.languageName.text == "English" }.productName.text,
          :low_price => (node.priceGuide.LOW.text.to_f * 100).round,
          :avg_price => (node.priceGuide.AVG.text.to_f * 100).round,
          :sell_price => (node.priceGuide.SELL.text.to_f * 100).round
        }
      end
    end
  end
end

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
