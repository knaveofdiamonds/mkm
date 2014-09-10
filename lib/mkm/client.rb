require 'oj'

module Mkm
  class Client
    def initialize(session)
      @session = session
    end

    def games
      parse(@session.get("games"), :game).
        each {|g| g[:id] = g.delete(:idGame) }
    end

    private

    def parse(response, root)
      Oj.load(response, symbol_keys: true)[root]
    end
  end
end
