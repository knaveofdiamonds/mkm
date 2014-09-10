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

  def sample_file(name)
    File.read(File.join(File.dirname(__FILE__), "samples", "#{name}.json"))
  end
end
