entity adder is
       -- i0, i1 and the carry-in ci are inputs of the adder.
       -- s is the sum output, co is the carry-out.
       port (i0, i1 : in bit; ci : in bit; s : out bit; co : out bit);
end adder;
     
architecture rtl of adder is begin
  s <= i0 xor i1 xor ci;
  co <= (i0 and i1) or (i0 and ci) or (i1 and ci);
end rtl;

