require_relative 'food_reader'

# read every age
Dir[File.dirname(__FILE__) + 'age/*'].each { |file| require_relative file }

# Tfaim
class Tfaim
  attr_accessor :additives, :concentration

end
