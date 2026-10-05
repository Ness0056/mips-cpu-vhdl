library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ROrgPrSimLib;
use ROrgPrSimLib.all;

use work.all;

entity neq4 is
    port(a : in std_logic_vector(3 downto 0);
         b : in std_logic_vector(3 downto 0);
         y : out std_logic);
end neq4;

architecture logic of neq4 is
begin
   y <= '0' when a = b else
       '1';
end logic;


architecture netlist of neq4 is
   signal s1, s2, s3, s4, s5, s6 : std_logic ;
begin
   u1: entity work.xor2(behavioral)
          port map(a => a(0),
                   b => b(0),
                   y => s1);
   u2: entity work.xor2(behavioral)
          port map(a => a(1),
                   b => b(1),
                   y => s2);
   u3: entity work.xor2(behavioral)
          port map(a => a(2),
                   b => b(2),
                   y => s3);
   u4: entity work.xor2(behavioral)
          port map(a => a(3),
                   b => b(3),
                   y => s4);
   o1: entity work.or2(behavioral)
          port map(a => s1,
                   b => s2,
                   y => s5);
   o2: entity work.or2(behavioral)
          port map(a => s3,
                   b => s4,
                   y => s6);
   o3: entity work.or2(behavioral)
          port map(a => s5,
                   b => s6,
                   y => y);
end netlist;
