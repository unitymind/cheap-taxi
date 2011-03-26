Rcov::FileStatistics.class_eval do
  def initialize_with_encoding(_, lines, *params)
    lines.each{|l| l.force_encoding("BINARY")}
    initialize_without_encoding(_, lines, *params)
  end
  alias_method(:initialize_without_encoding, :initialize)
  alias_method(:initialize, :initialize_with_encoding)
end