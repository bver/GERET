
module SelectMore

  attr_writer :unique_winners

  def unique_winners
    @unique_winners = false unless defined? @unique_winners
    @unique_winners
  end

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

