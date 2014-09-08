require 'faraday'
require 'ox'
require 'uri'
require 'simple_oauth'

module Mkm
  # Creates a new MKM client, given a user and an API key. You can
  # optionally pass a Faraday connection if you want custom HTTP
  # handling.
  def self.client(args)
    http = args[:http] || Faraday.new("https://www.mkmapi.eu")
    oauth = args[:oauth] or raise "You must provide Oauth Parameters"
    Client.new(Session.new(http, oauth), Parser.new)
  end

  # Interface to use MKM. Do not construct directly - see Mkm.client.
  class Client
    # @api private
    def initialize(session, parser)
      @session = session
      @parser = parser
    end

    def games
      @parser.parse_games @session.get("games")
    end

    def metaproduct(metaproduct_id)
      @parser.parse_metaproduct @session.get("metaproduct/#{metaproduct_id}")
    end

    def product(product_id)
      @parser.parse_product @session.get("product/#{product_id}")
    end

    def articles(product_id)
      @parser.parse_articles @session.get("articles/#{product_id}")
    end

    def product_by_name(name, game_id=1, language_id=1)
      @parser.parse_products _search(name, game_id, language_id, true)
    end

    def search(term, game_id=1, language_id=1)
      @parser.parse_products _search(term, game_id, language_id, false)
    end

    private

    def _search(term, game_id, language_id, exact)
      @session.get("products/#{URI.escape(term)}/#{game_id}/#{language_id}/#{exact}")
    end
  end

  # @api private
  class Session
    def initialize(http, oauth_parameters)
      @http = http
      @oauth_parameters = oauth_parameters
    end

    def get(partial_path)
      path = "/ws/v1.1/#{partial_path}"
      url = "https://www.mkmapi.eu#{path}"

      @http.get(path, {}, :authorization => oauth_header('get', url) ).body
    end

    private

    def oauth_header(m, url)
      SimpleOAuth::Header.new(m, url, {}, @oauth_parameters).to_s
    end
  end

  # @api private
  class Parser
    def parse_games(xml)
      parse(xml) {|node| game(node) }
    end

    def parse_products(xml)
      parse(xml) {|node| product(node) }
    end

    def parse_product(xml)
      parse_products(xml).first
    end

    def parse_articles(xml)
      parse(xml) {|node| article(node) }
    end

    def parse_metaproduct(xml)
      parse(xml) {|node| metaproduct(node) }.first
    end

    private

    def parse(xml)
      Ox.parse(xml).root.nodes.map {|n| yield n }
    end

    def game(node)
      { 
        :id   => node.idGame.text.to_i,
        :name => node.locate("name").first.text 
      }
    end

    def metaproduct(node)
      {
        :id => node.idMetaproduct.text.to_i,
        :name => node.locate("name").detect {|n| n.languageName.text == "English" }.metaproductName.text,
        :products => node.products.locate("idProduct").map {|n| n.text.to_i }
      }
    end

    def product(node)
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

    def article(node)
      {
        :id => node.idArticle.text.to_i,
        :product_id => node.idProduct.text.to_i,
        :comments => node.comments.text,
        :price => (node.price.to_f * 100).round,
        :count => node.count.to_i,
        :language => node.language.languageName.text,
        :condition => node.condition.text,
        :foil => node.isFoil.text == "true",
        :signed => node.isSigned.text == "true",
        :altered => node.isAltered.text == "true",
        :playset => node.isPlayset.text == "true",
        :seller => seller(node.seller)
      }
    end

    def seller(node)
      {
        :id => node.idUser.text.to_i,
        :username => node.username.text,
        :country => node.country.text,
        :commercial => node.isCommercial.text == "true",
        :risk_group => node.riskGroup.text.to_i,
        :reputation => node.reputation.text.to_i,
      }
    end
  end
end

class SimpleOAuth::Header
  # Monkey-patched to include the URL as the realm - this is what is
  # required by MKM.
  def to_s
    "OAuth realm=\"#{url}\", #{normalized_attributes}"
  end

  # Do not URI-escape OAuth parameters - this does not work with the
  # MKM API.
  def normalized_attributes
    signed_attributes.
      sort_by { |k, _| k.to_s }.
      collect { |k, v| %(#{k}="#{v}") }.
      join(', ')
  end
end
