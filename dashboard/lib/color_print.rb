module ColorPrint
  def color(msg, code)
    printf "\e[#{code}m#{msg}\e[0m\n"
  end

  def yellow(msg); color(msg, 33); end
  def blue(msg);   color(msg, 34); end
  def red(msg);    color(msg, 31); end
end
