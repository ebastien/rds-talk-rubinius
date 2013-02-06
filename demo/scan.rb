require "rubygems"
require "bundler/setup"
require "parslet"

module Scan
  class Instruction
    def bytecode(g)
      
      g.push_local 0
      
      g.push_local 0
      g.push_local 1
      g.meta_push_0
      g.send :fetch, 2, false

      g.push_local 0
      g.push_local 1
      g.meta_push_1
      g.meta_send_op_plus 0
      g.set_local 1
      g.meta_push_0
      g.send :fetch, 2, false

      g.meta_send_op_plus 0

      g.push_local 1
      g.swap_stack
      g.send :[]=, 2, false
      g.pop
    end
  end

  class Expression < Struct.new(:expr)
    def bytecode(g)
      expr.each { |e| e.bytecode(g) }
    end
  end

  class Lexer < Parslet::Parser
    alias_method :tokenize, :parse
    rule(:instr) { str('I') }
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
      @output.set_local 1

      (1..10).each do |m|
        @output.push_int m
      end

      @output.make_array 10
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
    stage :scan_code
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
    compiler = Rubinius::Compiler.new :scan_code, :compiled_method
    compiler.parser.input code, "(eval)", 1
    bytecode = compiler.run
    scope = ::Rubinius::StaticScope.new Object
    context = Object.new
    ::Rubinius.attach_method :__run__, bytecode, scope, context
    context.__run__
  end

end

puts Scan::compile("I" * 20).inspect

