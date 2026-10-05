library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mult25x18 is
    port(a : in signed(24 downto 0);
         b : in signed(17 downto 0);
         y : out signed(42 downto 0));
end mult25x18;

architecture behavioral of mult25x18 is
begin
    y <= a * b;
end behavioral;
