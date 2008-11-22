class Array
  def unshift?(item)
    tap do
      unshift(item) if item
    end
  end
end