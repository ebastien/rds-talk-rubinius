require "rubygems"
require "bundler/setup"
require 'parslet'

module OISC

  class Instruction
    def bytecode(g)
      g.meta_push_1
      g.meta_push_1
      g.meta_send_op_plus 0
      g.ret
    end
  end

  class Lexer < Parslet::Parser
    alias_method :tokenize, :parse
    rule(:instr) { str 'I' }
    rule(:expr) { instr.as :instr }
    root :expr
  end

  class Parser < Parslet::Transform
    rule(:instr => simple(:instr)) { Instruction.new }
  end

  class Generator < Rubinius::Compiler::Stage
    next_stage Rubinius::Compiler::Encoder

    def initialize(compiler, last)
      super
      compiler.generator = self
    end

    def run
      @output = Rubinius::Generator.new
      @output.set_line Integer(1)
      @input.bytecode @output
      @output.ret
      @output.close
      run_next
    end
  end

  class AST < Rubinius::Compiler::Stage
    next_stage Generator

    def run
      @output = Parser.new.apply @input
      run_next
    end
  end

  class Code < Rubinius::Compiler::Stage
    stage :oisc_code
    next_stage AST

    def initialize(compiler, last)
      super
      compiler.parser = self
    end

    def input(code, filename, line)
      @code = code
    end

    def run
      @output = Lexer.new.tokenize @code
      run_next
    end
  end

  def self.compile(code)
    compiler = Rubinius::Compiler.new :oisc_code, :compiled_method
    compiler.parser.input code, "(eval)", 1
    bytecode = compiler.run
    scope = ::Rubinius::StaticScope.new Object
    context = Object.new
    ::Rubinius.attach_method :__run__, bytecode, scope, context
    context.__run__
  end
end

puts OISC::compile("I").inspect
