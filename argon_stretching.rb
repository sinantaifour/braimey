require 'argon2'

class ArgonStretching
  def initialize(iterations)
    raise("Iterations should be between 1 and 750!") if iterations < 1 or iterations > 750
    @salt_size = 16
    @iterations = iterations
  end

  def expand_phrase(phrase)
    len = phrase.length
    raise("Pass phrase should be larger than #{@salt_size} in order to use argon expansion") unless len > @salt_size
    salt = phrase[0 .. @salt_size - 1]
    phrase = phrase[@salt_size..-1]
    raise unless salt.length == @salt_size
    raise unless phrase.length == len - @salt_size
    expander = Argon2::Password.new(t_cost: @iterations, m_cost: 16, salt_do_not_supply: salt)
    expander.create(phrase)
  end
end
