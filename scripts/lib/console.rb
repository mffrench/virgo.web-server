class Console

  def Console.change_title(prefix, title)
    print "\033]0;#{prefix}: #{title}\007"
  end

end
