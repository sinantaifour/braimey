require 'argon2'

class ArgonStretching
  SALT_SIZE = 16

  def initialize(iterations)
    raise("Iterations should be between 1 and 750!") if iterations < 1 or iterations > 750
    @iterations = iterations
  end

  def expand_phrase(phrase)
    len = phrase.length
    raise("Pass phrase should be larger than #{SALT_SIZE} in order to use argon expansion") unless len > SALT_SIZE
    salt = phrase[0..(SALT_SIZE - 1)]
    phrase = phrase[SALT_SIZE..-1]
    expander = Argon2::Password.new(t_cost: @iterations, m_cost: 16, salt_do_not_supply: salt)
    expander.create(phrase)
  end
end
