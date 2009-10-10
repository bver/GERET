 use std.textio.all; --  Imports the standard textio package.

     --  A testbench has no ports.
     entity adder_tb is
     end adder_tb;
     
     architecture behav of adder_tb is
        --  Declaration of the component that will be instantiated.
        component adder
          port (i0, i1 : in bit; ci : in bit; s : out bit; co : out bit);
        end component;
        --  Specifies which entity is bound with the component.
        for adder_0: adder use entity work.adder;
        signal i0, i1, ci, s, co : bit;
     begin
        --  Component instantiation.
        adder_0: adder port map (i0 => i0, i1 => i1, ci => ci,
                                 s => s, co => co);
     
        --  This process does the real job.
        process
           type pattern_type is record
              --  The inputs of the adder.
              i0, i1, ci : bit;
              --  The expected outputs of the adder.
              s, co : bit;
           end record;
        
           variable cnt : integer range 0 to 256 :=0;
           variable my_line : line;

           --  The patterns to apply.
           type pattern_array is array (natural range <>) of pattern_type;
           constant patterns : pattern_array :=
             (('0', '0', '0', '0', '0'),
              ('0', '0', '1', '1', '0'),
              ('0', '1', '0', '1', '0'),
              ('0', '1', '1', '0', '1'),
              ('1', '0', '0', '1', '0'),
              ('1', '0', '1', '0', '1'),
              ('1', '1', '0', '0', '1'),
              ('1', '1', '1', '1', '1'));
        begin
           --  Check each pattern.
           for i in patterns'range loop
              --  Set the inputs.
              i0 <= patterns(i).i0;
              i1 <= patterns(i).i1;
              ci <= patterns(i).ci;
              
              --  Wait for the results.
              wait for 1 ns;
              --  Check the outputs.

              if s = patterns(i).s then
                 cnt := cnt + 1;
              end if;

              if co = patterns(i).co then
                 cnt := cnt + 1; 
              end if;

           end loop;
           --assert false report "end of test" severity note;

           write(my_line, cnt);
           writeline (output, my_line);

           --  Wait forever; this will finish the simulation.
           wait;
          
        end process;
     end behav;


