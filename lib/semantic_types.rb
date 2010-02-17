
module Semantic

  AttrKey = Struct.new( 'AttrId', :token_id, :attr_idx )

  AttrRef = Struct.new( 'AttrRef', :node_idx, :attr_idx )

  AttrFn = Struct.new( 'AttrFn', :func, :target, :args, :orig )

  Attribute = Struct.new( 'Attribute', :value, :age )

  # reserved Attribute indices:
  AttrIndexText = 0   # _text
  #AttrIndexValid = 1  # _valid

end

