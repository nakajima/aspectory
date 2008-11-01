class Symbol
  def to_proc
    Proc.new { |i| i.send(self) }
  end
end