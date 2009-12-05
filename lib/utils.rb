
module Util
 
  def Util.statistics arr
    max = nil
    min = nil
    sum = 0.0
    n = 0

    arr.each do |i|
      next if i.nil?
      if i.to_f.infinite?
        max = i
        next
      end
      value = block_given? ? yield(i) : i
      max = (max.nil? || value>max) ? value : max
      min = (min.nil? || value<min) ? value : min
      sum += value
      n += 1
    end

    return min, max, sum/n, n    if n>0  
    return nil, nil, nil, 0
  end

  def Util.diversity arr
    count = Hash.new 0
    if block_given?
      arr.each { |val| count[ yield(val) ] += 1 }
    else
      arr.each { |val| count[ val ] += 1 }
    end
    count.values.sort {|a,b| b <=> a}
  end

  def Util.percent( nominator, denominator )
    if denominator == 0
      'N/A%'
    else
      "#{(100.0*nominator/denominator).round}%"
    end
  end

  def Util.permutate( arr, rnd=Kernel )
    src = arr.clone
    res = []
    until src.empty?
      i = rnd.rand src.size  
      res << src.delete_at( i )
    end
    res
  end
 
end
