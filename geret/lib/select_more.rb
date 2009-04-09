
module SelectMore

  def select( population, how_much )
    winners = []
    while winners.size < how_much
      winners << select_one( population )
    end
    winners
  end

end

