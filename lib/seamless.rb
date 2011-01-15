require 'polyglot'
require File.expand_path(File.join(File.dirname(__FILE__), 'seamless', 'endless'))

class EndlessRubyPolyglotLoader
  def self.load(filename, options = nil, &block)
    Endless.load(filename)
  end
end

Polyglot.register("rbe", EndlessRubyPolyglotLoader)
