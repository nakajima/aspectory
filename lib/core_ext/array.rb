class Array
  def enqueue(item)
    tap do
      unshift(item) if item
    end
  end
end