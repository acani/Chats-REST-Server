class Module
  def const_mock(const, mock)
    temp = const_get(const)
    const_set_silent(const, mock)
    yield
  ensure
    const_set_silent(const, temp)
  end

  # helper

  def const_set_silent(const, value)
    temp = $VERBOSE
    $VERBOSE = nil
    const_set(const, value)
  ensure
    $VERBOSE = temp
  end
end
