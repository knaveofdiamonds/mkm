require 'spec_helper'

describe Mkm::Session do
  let(:http) { double(:http_client) }
  let(:response) { double(:response, :body => "body") }

  it "gets the body of the response" do
    expect(SimpleOAuth::Header).to receive(:new).
      with("get", "https://www.mkmapi.eu/ws/v1.1/path", {}, :oauth).
      and_return("auth")
    
    expect(http).to receive(:get).with("/ws/v1.1/path", {}, :authorization => "auth").
      and_return(response)
    
    expect( described_class.new(http, :oauth).get("path") ).
      to eql("body")
  end
end
