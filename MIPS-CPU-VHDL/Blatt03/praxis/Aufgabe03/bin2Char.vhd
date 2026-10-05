library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin2Char is
    port(bin : in std_logic_vector(3 downto 0);
         bitmask : out std_logic_vector(6 downto 0));
end bin2Char;


architecture behavioral of bin2Char is
    type mapping_array is array (0 to 15) of std_logic_vector(6 downto 0);
    constant in_out_map : mapping_array := (
        "0111111",
        "0000110",
        "1011011",
        "1001111",
        "1100110",
        "1101101",
        "1111101",
        "0000111",
        "1111111",
        "1101111",
        "1110111",
        "1111100",
        "0111001",
        "1011110",
        "1111001",
        "1110001");

begin
    bitmask <= in_out_map(to_integer(unsigned(bin)));

end behavioral;
