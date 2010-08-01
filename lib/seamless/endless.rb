#############################################################################
# Note for seamless: This is from http://gist.github.com/117694, though     #
# heavily modified to meet clean code standards and remove some unnecessary #
# functionality.                                                            #
#############################################################################
#
# endless.rb is a pre-processor for ruby which allows you to use python-ish 
# indentation to delimit scopes, instead of having to type 'end' every time.
# 
# Basically, this makes the end keyword optional. If you leave off the
# end, the preprocessor inserts an end for you at the next line indented
# at or below the level of indentation of the line which started the scope.
# 
# End is optional, so you can still write things like this:
#   begin
#     do_something
#   end until done?
# (However, you'd better make damn sure you get the end indented to the 
# right level!)
# 
# This script uses RubyLexer to extract a stream of tokens and modify 
# it, then turn those tokens back into ruby code. Since RubyLexer is a 
# complete stand-alone lexer, this should be a very thorough solution,
# free of insoluable little problems due to the script's inability to 
# follow where comments and strings start and stop. (That said, I'm sure
# there will be some problems with it, as it's pretty raw code.)
# 
# As different programs have a variety of interpretations as to the
# width of a tab character, tabs for indentation are absolutely 
# forbidden by endless.rb.
# 
# There is a similar script, pyruby.rb, or pyrb.rb floating around which 
# examines a source file line by line and assumes lines ending in a colon 
# are the start of a block. Since pyrb.rb does not tokenize the input, 
# pyruby.rb can be fooled by a colon in a string or comment:
# 
#   p "a:
#      b"
#   p "a" #:
# 
# It's basically impossible to get this kind of thing right without actually
# tokenizing the input. Also, unlike python (and pyruby.rb), endless.rb needs
# no extra colon to start an indented block. (I don't like python's colons 
# much.)
# 
# Code written without ends must be pulled into the interpreter via special
# versions of the #load or #eval builtin methods. Eventually, there should
# be a version of #require as well, but for now you must get along with #load.
# The special versions are contained in the Endless module, so to load up 
# source code without ends in it, use 
#   Endless.load 'filename'
# instead of 
#   require 'filename' 
# or
#   load 'filename'

require 'rubylexer'
require 'tempfile'

class EndlessRubyLexer < RubyLexer
  def initialize(*args)
    @old_indent_levels=[]
    super
  end

  def old_indent_level
    @old_indent_levels.last
  end

  DONT_END = /^( *)(end|when|else|elsif|rescue|ensure)(?!#{LETTER_DIGIT}|[?!])/o

  def start_of_line_directives
    super

    if @file.check(/^( *)(.)/)
      lm = @file.last_match
      @indent_level = lm[1].size if lm[1]
      
      if lm[2] =~ /\A(?![ ])[\s\v]\Z/
        @indent_level = :invalid
      end

      if !(@parsestack.last.respond_to?(:in_body) && !@parsestack.last.in_body) &&
         (!@moretokens[-2] || NewlineToken === @moretokens[-2])
        #auto-terminate previous same or more indented want-end contexts
        pos = input_position
        while WantsEndContext===@parsestack.last and 
              @parsestack.last.indent_level > @indent_level
          insert_implicit_end pos
        end
        while WantsEndContext===@parsestack.last and 
              @parsestack.last.indent_level == @indent_level
          insert_implicit_end pos
        end unless @file.check DONT_END
      end
    end
  end

  def insert_implicit_end(pos)
    #emit implicit end token
    @moretokens.push WsToken.new(' ',pos), 
                     KeywordToken.new('end',pos), 
                     KeywordToken.new(';',pos)
    @parsestack.pop
  end   

  def indent_level
    return @indent_level if @indent_level.kind_of?(Integer)
    raise "invalid indentation: must use only spaces" 
  end

  def endoffile_detected(str='')
    result = super
    pos = input_position
    while WantsEndContext === @parsestack.last
      insert_implicit_end pos
    end
    @moretokens.push result
    return @moretokens.shift
  end

  def keyword_for(str, offset, result)
    result = super
    @parsestack[-2].indent_level = indent_level
    return result
  end

  def keyword_def(str, offset, result)
    fail unless @indent_level
    @old_indent_levels.push @indent_level
    result = super
    @old_indent_levels.pop

    return result
  end

  %w(module class begin case).each do |word|
    define_method "keyword_#{word}" do |str, offset, result|
      result = super
      @parsestack.last.indent_level = indent_level
      result
    end
  end
  
  %w(while until if unless).each do |word|
    define_method "keyword_#{word}" do |str, offset, result|
      result = super
      if @parsestack[-2].respond_to?(:indent_level=)
        @parsestack[-2].indent_level ||= indent_level
      end
      result
    end
  end

  def keyword_do(str,offset,result)
    result = super
    return result if ExpectDoOrNlContext === @parsestack.last
    
    ctx = @parsestack[-1]
    ctx = @parsestack[-2] if BlockParamListLhsContext === ctx
    ctx.indent_level = indent_level
    return result
  end
end

class RubyLexer::NestedContexts::WantsEndContext
  attr_accessor :indent_level
end

class RubyLexer::NestedContexts::DefContext
  alias_method :endful_see, :see
  def see(lxr,msg)
    if :semi == msg
      fail unless lxr.parsestack.last.equal? self
      @indent_level ||= lxr.old_indent_level
    end
    endful_see lxr, msg
  end
end

module Endless
  VERSION = "0.1.0"

  class << self
    def load(filename,wrap=false)
      [''].concat($:).each do |pre|
        pre += "/" unless pre.empty? || pre[-2,1] == '/'
        path = pre + filename
        if File.exist? path
          code = File.read(path)
          Tempfile.open(filename) do |f|
            preprocess code, filename, f
            f.rewind
            return ::Kernel::load(f.path, wrap)
          end
        end
      end
      raise LoadError, "no such file to load -- #{filename}"
    end

    def eval(code, file="(eval)", line=1, binding=nil)
      #binding should default to Binding.of_caller, not nil......
      eval(preprocess(code, file), file, line, binding)
    end

    def preprocess(code, filename, output='')
      lexer = EndlessRubyLexer.new(filename, code)
      printer = RubyLexer::KeepWsTokenPrinter.new

      begin
        tok = lexer.get1token
        output << printer.aprint(tok)
      end until RubyLexer::EoiToken === tok

      return output
    end

  end
end