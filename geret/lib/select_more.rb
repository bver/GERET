
module SelectMore

  attr_writer :unique_winners

  def unique_winners
    @unique_winners = false unless defined? @unique_winners
    @unique_winners
  end

  def select( population, how_much )
    winners = []
    while winners.size < how_much
      w = select_one( population )
      next if self.unique_winners and winners.include? w
      winners.push w
    end
    winners
  end

end

