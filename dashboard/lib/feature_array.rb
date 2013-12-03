class FeatureArray < Array
  def <<(obj)
    raise StandardError.new("This operation is not supported")
  end
end