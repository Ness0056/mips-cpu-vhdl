library ieee;
use ieee.std_logic_1164.all;

entity mux2 is
   port( a: in std_logic;
         b : in std_logic;
         s : in std_logic; 
         y : out std_logic );
end mux2;

architecture behavioral of mux2 is
begin
    y <= a when s = '0' else
         b when s = '1' else
         'X';

end behavioral ;

