class Method
  def arity_match?(collection)
    arity == -1 or arity == collection.length
  end
end