
module Semantic

  AttrKey = Struct.new( 'AttrId', :token_id, :attr_idx )

  AttrRef = Struct.new( 'AttrRef', :node_idx, :attr_idx )

  AttrFn = Struct.new( 'AttrFn', :func, :target, :args, :orig )

  # reserved Attribute indices:
  AttrIndices = [ '_text', '_valid' ]
  AttrIndexText =  AttrIndices.index( '_text' )
  AttrIndexValid = AttrIndices.index( '_valid' )
  
end

