
module Selection

# Helper module for various Selection methods.
# It provides unique_winners atribute support and the select method.
module SelectMore

  # Specify if the selection is without replacement (true means the results of 
  # the selection results are unique, false means the repetitions may occur).
  attr_writer :unique_winners

  # See unique_winners attribute.
  def unique_winners
    @unique_winners = false unless defined? @unique_winners
    @unique_winners
  end

  # Select more individuals from the population, assuming the user class provides select_one and
  # select_one_internal methods. 
  # It can be specified how_much individuals will be selected.
  def select( how_much, population=self.population )
    winners = [ select_one( population ) ]
    ids = [ winners.first.object_id ]
    while winners.size < how_much
      w = select_one_internal
      next if self.unique_winners and ids.include? w.object_id
      winners.push w
      ids.push w.object_id
    end
    winners
  end

end

end # Selection

