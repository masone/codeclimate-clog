require 'cc/engine/clog/issue/cyclomatic_complexity'
require 'cc/engine/clog/issue/file_length'
require 'cc/engine/clog/issue/function_length'
require 'cc/engine/clog/issue/token_complexity'

module CC
  module Engine
    module Clog
      class OutputInterpreter
        def initialize(path, result)
          @path = path
          @result = result
          @issues = []
        end

        attr_accessor :issues

        def call
          handle_cyclomatic_complexity
          handle_file_length
          handle_function_length
          handle_token_complexity
          self
        end

        private

        def handle_cyclomatic_complexity
          lengths = @result['cyclomaticComplexity']['lines'].select { |_, length| length > THRESHOLDS['cyclomatic_complexity'] }
          lengths.each do |line_range, length|
            from, to = parse_line_range(line_range)
            issues << Issue::CyclomaticComplexity.new(path: @path, length: length, from: from, to: to)
          end
        end

        def handle_file_length
          length = @result['functionLength']['total'] || 0
          return unless length > THRESHOLDS['file_length']

          issues << Issue::FileLength.new(path: @path, length: length)
        end

        def handle_function_length
          lengths = @result['functionLength']['lines'].select { |_, length| length > THRESHOLDS['function_length'] }
          lengths.each do |line_range, length|
            from, to = parse_line_range(line_range)
            issues << Issue::FunctionLength.new(path: @path, length: length, from: from, to: to)
          end
        end

        def handle_token_complexity
          token_complexity = @result['tokenComplexity'] || 0
          return unless token_complexity > THRESHOLDS['token_complexity']

          issues << Issue::TokenComplexity.new(path: @path, score: token_complexity)
        end

        def parse_line_range(range)
          range.split('-')
        end

        THRESHOLDS = {
          'token_complexity' => 100,
          'cyclomatic_complexity' => 5,
          'file_length' => 100,
          'function_length' => 15
        }.freeze
      end
    end
  end
end
