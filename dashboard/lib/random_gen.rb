=begin
  
  Usage: 
    RandomGen.uppercase_string(5)       #=> "AFMFY"
    RandomGen.alphanumeric_string(5)    #=> "w9t6F"
    RandomGen.string(['a','b','c'], 5)  #=> "baac" 

=end
module RandomGen
  
  @@alpha_upper = ('A'..'Z').to_a
  @@alpha_lower = ('a'..'z').to_a
  @@numeric = ('0'..'9').to_a
  @@alphanumeric = @@alpha_upper + @@alpha_lower + @@numeric
  
  class << self
    def uppercase_string(length)
      string(@@alpha_upper, length)
    end

    def alphanumeric_string(length)
      string(@@alphanumeric, length)
    end

    def string(choices, length)
      s = ''
      length.times { s << choices[rand(choices.size)] }
      s 
    end
  end

end

