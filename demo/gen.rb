require "rubygems"
require "bundler/setup"
require 'parslet'

module OISC

  class Instruction
    def bytecode(g)
      g.push_local 0            # 1

      g.push_local 0            # 2
      g.push_local 1            # 3
      g.meta_push_0             # 4
      g.send :fetch, 2, false   # 2

      g.push_local 0            # 3
      g.push_local 1            # 4
      g.meta_push_1             # 5
      g.meta_send_op_plus 0     # 4
      g.set_local 1
      g.meta_push_0             # 5
      g.send :fetch, 2, false   # 3

      g.meta_send_op_plus  0    # 2

      g.push_local 1            # 3
      g.swap_stack
      g.send :[]=, 2, false     # 1
      g.pop                     # 0
    end
  end

  class Expression < Struct.new(:expr)
    def bytecode(g)
      expr.each { |e| e.bytecode(g) }
    end
  end

  class Lexer < Parslet::Parser
    alias_method :tokenize, :parse
    rule(:instr) { str 'I' }
    rule(:expr) { instr.as(:instr).repeat.as(:expr) }
    root :expr
  end

  class Parser < Parslet::Transform
    rule(:instr => simple(:instr)) { Instruction.new }
    rule(:expr => subtree(:expr)) { Expression.new(expr) }
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
      
      @output.meta_push_0
      @output.set_local 1 # PC
      
      memory = (0..10).to_a
      memory.each do |m|
        @output.push_int m
      end
      @output.make_array memory.length
      @output.set_local 0

      @input.bytecode @output
      @output.use_detected
      @output.push_local 0
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

puts OISC::compile("I" * 10).inspect
