
module SelectMore

  attr_writer :unique_winners

  def unique_winners
    @unique_winners = false unless defined? @unique_winners
    @unique_winners
  end

  def select( how_much, population=self.population )
    winners = []
    ids = []
    while winners.size < how_much
      w = select_one( population )
      next if self.unique_winners and ids.include? w.object_id
      winners.push w
      ids.push w.object_id
    end
    winners
  end

end

