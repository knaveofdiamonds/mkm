require 'spec_helper'

describe SimpleOAuth::Header do
  let(:subject) {
    described_class.new("GET", url, {}, params).to_s
  }

  let(:params) {
    {
      consumer_key: "bfaD9xOU0SXBhtBP",
      consumer_secret: "pChvrpp6AEOEwxBIIUBOvWcRG3X9xL4Y",
      token: "lBY1xptUJ7ZJSK01x4fNwzw8kAe5b10Q",
      token_secret: "hc1wJAOX02pGGJK2uAv1ZOiwS7I9Tpoe",
      timestamp: "1407917892",
      nonce: "53eb1f44909d6"
    }
  }
  
  let(:url) { "https://www.mkmapi.eu/ws/v1.1/account" }

  context "Monkey-patches" do
    it "includes the realm" do
      expect(subject).to include("realm=\"#{url}\"")
    end

    it "includes the correct signature, unescaped" do
      expect(subject).to include("oauth_signature=\"DLGHHYV9OsbB/ARf73psEYaNWkI=\"")
    end
  end
end
