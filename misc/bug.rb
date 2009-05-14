#!/usr/bin/ruby -vw

  begin 
    Math::exp( Math::exp(42) ) 
  rescue
  end

  begin 
    eval "0.0/0.0"
  rescue
  end

