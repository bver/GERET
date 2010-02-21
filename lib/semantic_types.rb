
module Semantic

  # The key used in the internal AttributeGrammar#attributes hash.
  #   :token_id .. token.object_id identification of the particular token,
  #   :attr_idx .. attribute index in the Functions#attributes 
  AttrKey = Struct.new( 'AttrKey', :token_id, :attr_idx )

  # The attribute reference used in the Functions
  #   :node_idx .. index in the [parent, child0, child1 .. childN] array
  #   ;attr_idx .. attribute index in the Functions#attributes,
  # For example, AttrRef.new( 0, 1 ) means p._valid, AttrRef.new( 2, 0 ) means c1._text, etc.
  AttrRef = Struct.new( 'AttrRef', :node_idx, :attr_idx )

  # The semantic function.
  #   :func .. the actual compiled 'proc' (taking the array as the only parameter),
  #   :target .. AttrRef of the resulting attribute (the output of the semantic function),
  #   :args .. arguments array (containing AttrRefs of the attribute)
  #   :orig .. original source of the semantic function (same text as in the YAML file) for debuging purposes
  AttrFn = Struct.new( 'AttrFn', :func, :target, :args, :orig )

  # reserved Attribute indices:
  AttrIndices = [ '_text', '_valid' ]
  AttrIndexText =  AttrIndices.index( '_text' )
  AttrIndexValid = AttrIndices.index( '_valid' )
  
end

