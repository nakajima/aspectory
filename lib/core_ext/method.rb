class Method
  def same_arity?(collection)
    arity == -1 or arity == collection.length
  end
end