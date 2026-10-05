library ieee;
use ieee.std_logic_1164.all;

entity xor2 is
    port (
        a : in std_logic;
        b : in std_logic;
        y : out std_logic
    );
end xor2;

architecture behavioral of xor2 is
begin
    y <= a xor b;
end architecture;
