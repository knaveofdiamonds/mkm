require 'spec_helper'

describe Mkm::Client do
  let(:parser) { double(:parser) }
  let(:session) { double(:session) }
  let(:response) { "body" }

  subject { described_class.new(session, parser) }

  it "retrieves games" do
    expect(session).to receive(:get).with("games").and_return(response)
    expect(parser).to receive(:parse_games).with(response)

    subject.games
  end

  it "retrieves products by name" do
    expect(session).to receive(:get).with("products/jace%20beleren/1/1/true").
      and_return(response)
    expect(parser).to receive(:parse_products).with(response)

    subject.product_by_name("jace beleren")
  end

  it "searches for products" do
    expect(session).to receive(:get).with("products/jace/1/1/false").
      and_return(response)
    expect(parser).to receive(:parse_products).with(response)

    subject.search("jace")
  end

  it "returns the metaproduct" do
    expect(session).to receive(:get).with("metaproduct/2").
      and_return(response)
    expect(parser).to receive(:parse_metaproduct).with(response)

    subject.metaproduct(2)
  end

  it "returns the product" do
    expect(session).to receive(:get).with("product/2").
      and_return(response)
    expect(parser).to receive(:parse_product).with(response)

    subject.product(2)
  end

  it "returns articles" do
    expect(session).to receive(:get).with("articles/2").
      and_return(response)
    expect(parser).to receive(:parse_articles).with(response)

    subject.articles(2)
  end
end
