require 'spec_helper'

describe Mkm::Client do
  let(:session) { double(:session) }
  let(:client) { described_class.new(session) }

  describe "#games" do
    before :each do
      allow(session).to receive(:get).with("games").
        and_return(sample_file('games'))
    end

    it "returns a list of Games" do
      expect(client.games.size).to eql(5)
    end

    it "returns games with name attributes" do
      expect(client.games.first[:name]).to eql("Magic the Gathering")
    end

    it "returns games with id attributes" do
      expect(client.games.first[:id]).to eql(1)
    end
  end

  describe "retrieving products" do
    before :each do
      allow(session).to receive(:get).and_return(sample_file('products'))
    end

    it "asks for MtG products in English by default" do
      expect(session).to receive(:get).with("products/shock/1/1/true").
        and_return(sample_file('products'))

      client.card_by_name("shock")
    end

    it "asks for products for a specific game" do
      expect(session).to receive(:get).with("products/shock/2/1/true").
        and_return(sample_file('products'))

      client.card_by_name("shock", 2)
    end

    it "asks for products in a specific language" do
      expect(session).to receive(:get).with("products/shock/1/2/true").
        and_return(sample_file('products'))

      client.card_by_name("shock", 1, 2)
    end

    it "can search for products" do
      expect(session).to receive(:get).with("products/shock/1/1/false").
        and_return(sample_file('products'))

      client.search("shock")
    end

    it "escapes product names correctly and removes punctuation" do
      expect(session).to receive(:get).
        with("products/councils%20judgment/1/1/true").
        and_return(sample_file('products'))

      client.card_by_name("Council's Judgment")
    end

    it "returns a list of products" do
      expect(client.card_by_name("shock").size).to eql(1)
    end
  end

  def sample_file(name)
    File.read(File.join(File.dirname(__FILE__), "samples", "#{name}.json"))
  end
end
