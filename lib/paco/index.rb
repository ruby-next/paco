module Paco
  Index = Struct.new(:pos, :line, :column) do
    # @param [String] input
    # @param [Integer] pos
    def self.calculate(input:, pos:)
      raise ArgumentError, "`pos` must be a non-negative integer" if pos < 0
      raise ArgumentError, "`pos` is greater then input length" if pos > input.length

      lines = input[0..pos].lines
      line = lines.empty? ? 1 : lines.length
      column = lines.last&.length || 1
      new(pos, line, column)
    end
  end
end
