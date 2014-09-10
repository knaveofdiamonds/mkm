require 'simple_oauth'

module Mkm
  # @api private
  class Session
    def initialize(http, oauth_parameters)
      @http = http
      @oauth_parameters = oauth_parameters
    end

    def get(partial_path)
      path = "/ws/v1.1/output.json/#{partial_path}"
      url = "https://www.mkmapi.eu#{path}"

      @http.get(path, {}, :authorization => oauth_header('get', url) ).body
    end

    private

    def oauth_header(m, url)
      OAuthHeader.new(m, url, {}, @oauth_parameters).to_s
    end
  end

  # @api private
  class OAuthHeader < SimpleOAuth::Header
    # Overridden to include the URL as the realm - this is what is
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
end
