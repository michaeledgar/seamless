require 'polyglot'
require 'seamless/endless'

class EndlessRubyPolyglotLoader
  def self.load(filename, options = nil, &block)
    Endless.load(filename)
  end
end

Polyglot.register("rbe", EndlessRubyPolyglotLoader)