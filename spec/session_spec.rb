require 'spec_helper'

describe Mkm::Session do
  let(:http) { double(:http_client) }
  let(:response) { double(:response, :body => "body") }
  it "returns the body of the response" do
    expect(http).to receive(:get).with("/ws/user/key/path").
      and_return(response)

    expect( described_class.new("user", "key", http).get("path") ).
      to eql("body")
  end
end
